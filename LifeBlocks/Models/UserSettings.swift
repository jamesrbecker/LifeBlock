import Foundation
import SwiftData

// MARK: - Shared Profile (Privacy-Filtered)
/// What friends can see based on your privacy settings

struct SharedProfile: Codable {
    let displayName: String
    let avatarEmoji: String
    let bio: String?               // nil if private or empty
    let currentStreak: Int?        // nil if private
    let longestStreak: Int?        // nil if private
    let weeklyScore: Int?          // nil if private
    let isActive: Bool?            // nil if private
    let path: String?              // nil if private
    let isPrivate: Bool            // true = full privacy mode

    /// Description for UI display
    var privacyDescription: String {
        if isPrivate {
            return "This user has enabled private mode"
        }
        return ""
    }
}

@Model
final class UserSettings {
    var id: UUID
    var hasCompletedOnboarding: Bool
    var reminderTime: Date
    var reminderEnabled: Bool
    var healthKitEnabled: Bool
    var weekStartsOnMonday: Bool
    var selectedTheme: String
    var createdAt: Date

    init() {
        self.id = UUID()
        self.hasCompletedOnboarding = false

        // Default reminder at 8 PM
        var components = DateComponents()
        components.hour = 20
        components.minute = 0
        self.reminderTime = Calendar.current.date(from: components) ?? Date()

        self.reminderEnabled = true
        self.healthKitEnabled = false
        self.weekStartsOnMonday = true
        self.selectedTheme = "skyblue"
        self.createdAt = Date()
    }

    var reminderTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
}

// App-wide settings manager using UserDefaults for quick access
final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    private let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard

    private init() {}

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: "hasCompletedOnboarding") }
        set { defaults.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    var isPremium: Bool {
        get { defaults.bool(forKey: "isPremium") }
        set { defaults.set(newValue, forKey: "isPremium") }
    }

    var currentStreak: Int {
        get { defaults.integer(forKey: "currentStreak") }
        set { defaults.set(newValue, forKey: "currentStreak") }
    }

    var longestStreak: Int {
        get { defaults.integer(forKey: "longestStreak") }
        set { defaults.set(newValue, forKey: "longestStreak") }
    }

    var lastCheckInDate: Date? {
        get { defaults.object(forKey: "lastCheckInDate") as? Date }
        set { defaults.set(newValue, forKey: "lastCheckInDate") }
    }

    var todayScore: Int {
        get { defaults.integer(forKey: "todayScore") }
        set { defaults.set(newValue, forKey: "todayScore") }
    }

    // MARK: - Path Discovery

    /// Date the user first launched the app
    var firstLaunchDate: Date {
        get {
            if let date = defaults.object(forKey: "firstLaunchDate") as? Date {
                return date
            }
            // If not set, set it now
            let now = Date()
            defaults.set(now, forKey: "firstLaunchDate")
            return now
        }
        set { defaults.set(newValue, forKey: "firstLaunchDate") }
    }

    /// Whether user has dismissed the path suggestion prompt
    var hasDeclinedPathSuggestion: Bool {
        get { defaults.bool(forKey: "hasDeclinedPathSuggestion") }
        set { defaults.set(newValue, forKey: "hasDeclinedPathSuggestion") }
    }

    /// Days since user started using the app
    var daysUsingApp: Int {
        Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
    }

    /// Should we show the path discovery prompt?
    var shouldShowPathDiscoveryPrompt: Bool {
        // Only show if:
        // 1. User has no path set
        // 2. User hasn't declined the suggestion
        // 3. User has been using app for 7+ days
        // 4. User has checked in at least 5 times (showing engagement)
        guard userLifePath == nil else { return false }
        guard !hasDeclinedPathSuggestion else { return false }
        guard daysUsingApp >= 7 else { return false }
        guard currentStreak >= 3 || longestStreak >= 5 else { return false }
        return true
    }

    /// User chose to explore without a specific path
    var isExplorationMode: Bool {
        get { defaults.bool(forKey: "isExplorationMode") }
        set { defaults.set(newValue, forKey: "isExplorationMode") }
    }

    // MARK: - Multiple Paths (Premium Feature)

    /// Secondary path for users tracking multiple life areas
    var secondaryPath: LifePathCategory? {
        get {
            guard let rawValue = defaults.string(forKey: "secondaryPath") else { return nil }
            return LifePathCategory(rawValue: rawValue)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: "secondaryPath")
        }
    }

    /// Tertiary path for power users
    var tertiaryPath: LifePathCategory? {
        get {
            guard let rawValue = defaults.string(forKey: "tertiaryPath") else { return nil }
            return LifePathCategory(rawValue: rawValue)
        }
        set {
            defaults.set(newValue?.rawValue, forKey: "tertiaryPath")
        }
    }

    /// All active paths (primary + secondary + tertiary)
    var activePaths: [LifePathCategory] {
        var paths: [LifePathCategory] = []
        if let primary = userLifePath?.selectedPath {
            paths.append(primary)
        }
        if let secondary = secondaryPath {
            paths.append(secondary)
        }
        if let tertiary = tertiaryPath {
            paths.append(tertiary)
        }
        return paths
    }

    /// Maximum number of paths allowed based on subscription
    var maxPaths: Int {
        isPremium ? 3 : 1
    }

    // MARK: - Streak Protection (Freeze Days)

    /// Number of freeze days available this month
    var freezeDaysRemaining: Int {
        get { defaults.integer(forKey: "freezeDaysRemaining") }
        set { defaults.set(newValue, forKey: "freezeDaysRemaining") }
    }

    /// Last month freeze days were reset
    var freezeDaysResetMonth: Int {
        get { defaults.integer(forKey: "freezeDaysResetMonth") }
        set { defaults.set(newValue, forKey: "freezeDaysResetMonth") }
    }

    /// Dates that have been frozen (streak protected)
    var frozenDates: [Date] {
        get {
            guard let data = defaults.data(forKey: "frozenDates"),
                  let dates = try? JSONDecoder().decode([Date].self, from: data) else {
                return []
            }
            return dates
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: "frozenDates")
            }
        }
    }

    /// Maximum freeze days per month based on subscription
    var maxFreezeDaysPerMonth: Int {
        isPremium ? 3 : 1
    }

    /// Reset freeze days if new month
    func resetFreezeDaysIfNeeded() {
        let currentMonth = Calendar.current.component(.month, from: Date())
        if freezeDaysResetMonth != currentMonth {
            freezeDaysRemaining = maxFreezeDaysPerMonth
            freezeDaysResetMonth = currentMonth
        }
    }

    /// Use a freeze day for a specific date
    func useFreezeDay(for date: Date) -> Bool {
        resetFreezeDaysIfNeeded()
        guard freezeDaysRemaining > 0 else { return false }

        let dayStart = Calendar.current.startOfDay(for: date)
        var dates = frozenDates
        if !dates.contains(where: { Calendar.current.isDate($0, inSameDayAs: dayStart) }) {
            dates.append(dayStart)
            frozenDates = dates
            freezeDaysRemaining -= 1
            return true
        }
        return false
    }

    /// Check if a date is frozen
    func isDateFrozen(_ date: Date) -> Bool {
        let dayStart = Calendar.current.startOfDay(for: date)
        return frozenDates.contains { Calendar.current.isDate($0, inSameDayAs: dayStart) }
    }

    // MARK: - Milestone Tracking

    /// Last celebrated milestone
    var lastCelebratedMilestone: Int {
        get { defaults.integer(forKey: "lastCelebratedMilestone") }
        set { defaults.set(newValue, forKey: "lastCelebratedMilestone") }
    }

    /// Check if there's a new milestone to celebrate
    var pendingMilestone: Int? {
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365, 500, 1000]
        for milestone in milestones {
            if currentStreak >= milestone && lastCelebratedMilestone < milestone {
                return milestone
            }
        }
        return nil
    }

    /// Mark milestone as celebrated
    func celebrateMilestone(_ milestone: Int) {
        lastCelebratedMilestone = milestone
    }

    // MARK: - Referral System

    var referralCode: String {
        get {
            if let code = defaults.string(forKey: "referralCode"), !code.isEmpty {
                return code
            }
            // Generate new code
            let newCode = generateReferralCode()
            defaults.set(newCode, forKey: "referralCode")
            return newCode
        }
        set { defaults.set(newValue, forKey: "referralCode") }
    }

    var referralCount: Int {
        get { defaults.integer(forKey: "referralCount") }
        set { defaults.set(newValue, forKey: "referralCount") }
    }

    var earnedPremiumDays: Int {
        get { defaults.integer(forKey: "earnedPremiumDays") }
        set { defaults.set(newValue, forKey: "earnedPremiumDays") }
    }

    private func generateReferralCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return "LB" + String((0..<6).map { _ in letters.randomElement()! })
    }

    // MARK: - Theme Settings

    var isDarkMode: Bool {
        get { defaults.object(forKey: "isDarkMode") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "isDarkMode") }
    }

    var colorSchemeOverride: String? {
        get { defaults.string(forKey: "colorSchemeOverride") }
        set {
            defaults.set(newValue, forKey: "colorSchemeOverride")
            objectWillChange.send()
        }
    }

    // MARK: - Family Plan

    var isFamilyAdmin: Bool {
        get { defaults.bool(forKey: "isFamilyAdmin") }
        set { defaults.set(newValue, forKey: "isFamilyAdmin") }
    }

    var familyGroupId: String? {
        get { defaults.string(forKey: "familyGroupId") }
        set { defaults.set(newValue, forKey: "familyGroupId") }
    }

    var familyMemberCount: Int {
        get { defaults.integer(forKey: "familyMemberCount") }
        set { defaults.set(newValue, forKey: "familyMemberCount") }
    }

    // MARK: - Privacy Settings
    // Privacy-first approach: users control exactly what friends can see

    /// Master privacy mode - when enabled, you appear completely private
    var isPrivateMode: Bool {
        get { defaults.bool(forKey: "isPrivateMode") }
        set { defaults.set(newValue, forKey: "isPrivateMode") }
    }

    /// Share current streak with friends
    var shareStreak: Bool {
        get { defaults.object(forKey: "shareStreak") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "shareStreak") }
    }

    /// Share weekly activity score with friends
    var shareWeeklyScore: Bool {
        get { defaults.object(forKey: "shareWeeklyScore") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "shareWeeklyScore") }
    }

    /// Share that you checked in today (no details, just activity indicator)
    var shareActivityStatus: Bool {
        get { defaults.object(forKey: "shareActivityStatus") as? Bool ?? true }  // Default ON - minimal
        set { defaults.set(newValue, forKey: "shareActivityStatus") }
    }

    /// Share your path/goals with friends (always private by default)
    var sharePathAndGoals: Bool {
        get { defaults.object(forKey: "sharePathAndGoals") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "sharePathAndGoals") }
    }

    /// Share achievements/milestones with friends
    var shareAchievements: Bool {
        get { defaults.object(forKey: "shareAchievements") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "shareAchievements") }
    }

    /// Share longest streak with friends
    var shareLongestStreak: Bool {
        get { defaults.object(forKey: "shareLongestStreak") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "shareLongestStreak") }
    }

    /// Appear on leaderboards
    var appearOnLeaderboards: Bool {
        get { defaults.object(forKey: "appearOnLeaderboards") as? Bool ?? false }  // Default OFF
        set { defaults.set(newValue, forKey: "appearOnLeaderboards") }
    }

    /// Allow friends to send you cheers
    var allowCheers: Bool {
        get { defaults.object(forKey: "allowCheers") as? Bool ?? true }  // Default ON
        set { defaults.set(newValue, forKey: "allowCheers") }
    }

    /// Show your display name or anonymous
    var useAnonymousName: Bool {
        get { defaults.bool(forKey: "useAnonymousName") }
        set { defaults.set(newValue, forKey: "useAnonymousName") }
    }

    // MARK: - Bio (Premium Feature)

    /// Short bio visible on leaderboards and friend profiles (premium only, max 80 chars)
    var bio: String {
        get { defaults.string(forKey: "userBio") ?? "" }
        set { defaults.set(String(newValue.prefix(80)), forKey: "userBio") }
    }

    /// Get the display name respecting privacy settings
    var publicDisplayName: String {
        if isPrivateMode || useAnonymousName {
            return "Anonymous"
        }
        return displayName
    }

    /// Get a privacy-filtered profile for sharing with friends
    func getSharedProfile() -> SharedProfile {
        SharedProfile(
            displayName: publicDisplayName,
            avatarEmoji: isPrivateMode ? "🔒" : avatarEmoji,
            bio: isPrivateMode ? nil : (bio.isEmpty ? nil : bio),
            currentStreak: shareStreak ? currentStreak : nil,
            longestStreak: shareLongestStreak ? longestStreak : nil,
            weeklyScore: shareWeeklyScore ? weeklyScore : nil,
            isActive: shareActivityStatus ? (lastCheckInDate?.isToday ?? false) : nil,
            path: sharePathAndGoals ? userLifePath?.selectedPath.rawValue : nil,
            isPrivate: isPrivateMode
        )
    }

    // MARK: - Analytics Tracking

    var checkInTimes: [Date] {
        get {
            guard let data = defaults.data(forKey: "checkInTimes"),
                  let times = try? JSONDecoder().decode([Date].self, from: data) else {
                return []
            }
            return times
        }
        set {
            // Keep last 90 days of check-in times
            let cutoff = Calendar.current.date(byAdding: .day, value: -90, to: Date())!
            let filtered = newValue.filter { $0 > cutoff }
            if let data = try? JSONEncoder().encode(filtered) {
                defaults.set(data, forKey: "checkInTimes")
            }
        }
    }

    func recordCheckInTime() {
        var times = checkInTimes
        times.append(Date())
        checkInTimes = times
    }

    // MARK: - Streak Update with Freeze Support

    func updateStreak(checkedInToday: Bool) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = lastCheckInDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysSinceLast = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysSinceLast == 1 && checkedInToday {
                // Consecutive day
                currentStreak += 1
            } else if daysSinceLast > 1 {
                // Check if all missed days were frozen
                var allFrozen = true
                for i in 1..<daysSinceLast {
                    if let missedDate = calendar.date(byAdding: .day, value: i, to: lastDay) {
                        if !isDateFrozen(missedDate) {
                            allFrozen = false
                            break
                        }
                    }
                }

                if allFrozen && checkedInToday {
                    // Streak preserved by freeze days
                    currentStreak += 1
                } else {
                    // Streak broken
                    currentStreak = checkedInToday ? 1 : 0
                }
            }
        } else if checkedInToday {
            currentStreak = 1
        }

        if checkedInToday {
            lastCheckInDate = today
            longestStreak = max(longestStreak, currentStreak)
            recordCheckInTime()
        }
    }
}
