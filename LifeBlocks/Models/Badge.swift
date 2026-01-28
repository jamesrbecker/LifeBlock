import Foundation
import SwiftUI

// MARK: - Badge Definition

struct Badge: Identifiable, Hashable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let category: BadgeCategory
    let requirement: BadgeRequirement
    let tier: BadgeTier

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Badge, rhs: Badge) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Badge Category

enum BadgeCategory: String, CaseIterable {
    case streak = "Streak"
    case completion = "Completion"
    case consistency = "Consistency"
    case social = "Social"
    case milestone = "Milestone"

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .completion: return "checkmark.circle.fill"
        case .consistency: return "calendar"
        case .social: return "person.2.fill"
        case .milestone: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .streak: return .orange
        case .completion: return .green
        case .consistency: return .blue
        case .social: return .purple
        case .milestone: return .yellow
        }
    }
}

// MARK: - Badge Tier

enum BadgeTier: Int, CaseIterable, Comparable {
    case bronze = 1
    case silver = 2
    case gold = 3
    case platinum = 4

    var displayName: String {
        switch self {
        case .bronze: return "Bronze"
        case .silver: return "Silver"
        case .gold: return "Gold"
        case .platinum: return "Platinum"
        }
    }

    var color: Color {
        switch self {
        case .bronze: return Color(red: 0.8, green: 0.5, blue: 0.2)
        case .silver: return Color(red: 0.75, green: 0.75, blue: 0.8)
        case .gold: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .platinum: return Color(red: 0.4, green: 0.8, blue: 0.9)
        }
    }

    static func < (lhs: BadgeTier, rhs: BadgeTier) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

// MARK: - Badge Requirement

enum BadgeRequirement {
    case currentStreak(Int)
    case longestStreak(Int)
    case totalCompletions(Int)
    case perfectWeeks(Int)
    case totalCheckIns(Int)
    case friendsAdded(Int)
    case cheersGiven(Int)
    case habitsCreated(Int)
    case daysUsingApp(Int)

    var progressDescription: String {
        switch self {
        case .currentStreak(let n): return "\(n)-day streak"
        case .longestStreak(let n): return "Reach a \(n)-day streak"
        case .totalCompletions(let n): return "\(n) total completions"
        case .perfectWeeks(let n): return "\(n) perfect week\(n == 1 ? "" : "s")"
        case .totalCheckIns(let n): return "\(n) check-ins"
        case .friendsAdded(let n): return "Add \(n) friend\(n == 1 ? "" : "s")"
        case .cheersGiven(let n): return "Send \(n) cheer\(n == 1 ? "" : "s")"
        case .habitsCreated(let n): return "Create \(n) habit\(n == 1 ? "" : "s")"
        case .daysUsingApp(let n): return "Use app for \(n) day\(n == 1 ? "" : "s")"
        }
    }
}

// MARK: - Badge Catalog

struct BadgeCatalog {

    static let allBadges: [Badge] = streakBadges + completionBadges + consistencyBadges + socialBadges + milestoneBadges

    // MARK: - Streak Badges

    static let streakBadges: [Badge] = [
        Badge(id: "streak_3", name: "Getting Started", icon: "flame", description: "Maintain a 3-day streak", category: .streak, requirement: .currentStreak(3), tier: .bronze),
        Badge(id: "streak_7", name: "Week Warrior", icon: "flame.fill", description: "Maintain a 7-day streak", category: .streak, requirement: .currentStreak(7), tier: .bronze),
        Badge(id: "streak_14", name: "Dedicated", icon: "flame.fill", description: "Maintain a 14-day streak", category: .streak, requirement: .currentStreak(14), tier: .silver),
        Badge(id: "streak_30", name: "Monthly Master", icon: "flame.fill", description: "Maintain a 30-day streak", category: .streak, requirement: .currentStreak(30), tier: .silver),
        Badge(id: "streak_60", name: "Unstoppable", icon: "flame.fill", description: "Maintain a 60-day streak", category: .streak, requirement: .currentStreak(60), tier: .gold),
        Badge(id: "streak_100", name: "Century", icon: "flame.fill", description: "Maintain a 100-day streak", category: .streak, requirement: .currentStreak(100), tier: .gold),
        Badge(id: "streak_365", name: "Year of Commitment", icon: "flame.fill", description: "Maintain a 365-day streak", category: .streak, requirement: .currentStreak(365), tier: .platinum),
    ]

    // MARK: - Completion Badges

    static let completionBadges: [Badge] = [
        Badge(id: "comp_10", name: "First Steps", icon: "footprints", description: "Complete 10 habit check-ins", category: .completion, requirement: .totalCheckIns(10), tier: .bronze),
        Badge(id: "comp_50", name: "Building Momentum", icon: "arrow.up.right", description: "Complete 50 habit check-ins", category: .completion, requirement: .totalCheckIns(50), tier: .bronze),
        Badge(id: "comp_100", name: "Triple Digits", icon: "checkmark.circle.fill", description: "Complete 100 habit check-ins", category: .completion, requirement: .totalCheckIns(100), tier: .silver),
        Badge(id: "comp_500", name: "Habit Machine", icon: "gearshape.2.fill", description: "Complete 500 habit check-ins", category: .completion, requirement: .totalCheckIns(500), tier: .gold),
        Badge(id: "comp_1000", name: "Legendary", icon: "crown.fill", description: "Complete 1,000 habit check-ins", category: .completion, requirement: .totalCheckIns(1000), tier: .platinum),
    ]

    // MARK: - Consistency Badges

    static let consistencyBadges: [Badge] = [
        Badge(id: "perfect_week_1", name: "Perfect Week", icon: "star", description: "Score a perfect week (7/7 days)", category: .consistency, requirement: .perfectWeeks(1), tier: .bronze),
        Badge(id: "perfect_week_4", name: "Perfect Month", icon: "star.fill", description: "Score 4 perfect weeks", category: .consistency, requirement: .perfectWeeks(4), tier: .silver),
        Badge(id: "perfect_week_12", name: "Quarter Champion", icon: "star.circle.fill", description: "Score 12 perfect weeks", category: .consistency, requirement: .perfectWeeks(12), tier: .gold),
        Badge(id: "perfect_week_52", name: "Year of Excellence", icon: "star.square.fill", description: "Score 52 perfect weeks", category: .consistency, requirement: .perfectWeeks(52), tier: .platinum),
    ]

    // MARK: - Social Badges

    static let socialBadges: [Badge] = [
        Badge(id: "friend_1", name: "Social Butterfly", icon: "person.badge.plus", description: "Add your first friend", category: .social, requirement: .friendsAdded(1), tier: .bronze),
        Badge(id: "friend_5", name: "Squad Goals", icon: "person.3.fill", description: "Add 5 friends", category: .social, requirement: .friendsAdded(5), tier: .silver),
        Badge(id: "cheer_10", name: "Cheerleader", icon: "hands.clap.fill", description: "Send 10 cheers to friends", category: .social, requirement: .cheersGiven(10), tier: .bronze),
        Badge(id: "cheer_50", name: "Hype Machine", icon: "megaphone.fill", description: "Send 50 cheers to friends", category: .social, requirement: .cheersGiven(50), tier: .silver),
    ]

    // MARK: - Milestone Badges

    static let milestoneBadges: [Badge] = [
        Badge(id: "habits_3", name: "Habit Builder", icon: "hammer.fill", description: "Create 3 custom habits", category: .milestone, requirement: .habitsCreated(3), tier: .bronze),
        Badge(id: "habits_10", name: "Habit Architect", icon: "building.2.fill", description: "Create 10 custom habits", category: .milestone, requirement: .habitsCreated(10), tier: .silver),
        Badge(id: "days_30", name: "30 Day Club", icon: "calendar.badge.checkmark", description: "Use LifeBlocks for 30 days", category: .milestone, requirement: .daysUsingApp(30), tier: .bronze),
        Badge(id: "days_100", name: "Century Club", icon: "100.circle.fill", description: "Use LifeBlocks for 100 days", category: .milestone, requirement: .daysUsingApp(100), tier: .silver),
        Badge(id: "days_365", name: "One Year Strong", icon: "trophy.fill", description: "Use LifeBlocks for 365 days", category: .milestone, requirement: .daysUsingApp(365), tier: .gold),
    ]
}

// MARK: - Badge Progress Tracker

@MainActor
final class BadgeTracker: ObservableObject {
    static let shared = BadgeTracker()

    private let defaults = UserDefaults.standard
    private let earnedBadgesKey = "earnedBadgeIDs"
    private let perfectWeeksKey = "perfectWeeksCount"
    private let cheersGivenKey = "cheersGivenCount"

    @Published var earnedBadgeIDs: Set<String> = []

    private init() {
        loadEarnedBadges()
    }

    private func loadEarnedBadges() {
        let ids = defaults.stringArray(forKey: earnedBadgesKey) ?? []
        earnedBadgeIDs = Set(ids)
    }

    private func saveEarnedBadges() {
        defaults.set(Array(earnedBadgeIDs), forKey: earnedBadgesKey)
    }

    func isEarned(_ badge: Badge) -> Bool {
        earnedBadgeIDs.contains(badge.id)
    }

    func earnBadge(_ badge: Badge) {
        guard !earnedBadgeIDs.contains(badge.id) else { return }
        earnedBadgeIDs.insert(badge.id)
        saveEarnedBadges()
    }

    var earnedCount: Int {
        earnedBadgeIDs.count
    }

    var totalCount: Int {
        BadgeCatalog.allBadges.count
    }

    // MARK: - Progress Tracking

    var perfectWeeksCount: Int {
        get { defaults.integer(forKey: perfectWeeksKey) }
        set { defaults.set(newValue, forKey: perfectWeeksKey) }
    }

    var cheersGivenCount: Int {
        get { defaults.integer(forKey: cheersGivenKey) }
        set { defaults.set(newValue, forKey: cheersGivenKey) }
    }

    func incrementCheersGiven() {
        cheersGivenCount += 1
        checkAndAwardBadges()
    }

    func incrementPerfectWeeks() {
        perfectWeeksCount += 1
        checkAndAwardBadges()
    }

    // MARK: - Badge Checking

    /// Check all badges and award any that are newly earned
    func checkAndAwardBadges() {
        let settings = AppSettings.shared

        for badge in BadgeCatalog.allBadges {
            guard !isEarned(badge) else { continue }

            let earned: Bool
            switch badge.requirement {
            case .currentStreak(let n):
                earned = settings.currentStreak >= n
            case .longestStreak(let n):
                earned = settings.longestStreak >= n
            case .totalCompletions(let n):
                // Use total check-ins from check-in times array as proxy
                earned = settings.checkInTimes.count >= n
            case .perfectWeeks(let n):
                earned = perfectWeeksCount >= n
            case .totalCheckIns(let n):
                earned = settings.checkInTimes.count >= n
            case .friendsAdded(let n):
                // We'll check friend count from friend code usage
                earned = defaults.integer(forKey: "friendsCount") >= n
            case .cheersGiven(let n):
                earned = cheersGivenCount >= n
            case .habitsCreated(let n):
                earned = defaults.integer(forKey: "customHabitsCreated") >= n
            case .daysUsingApp(let n):
                earned = settings.daysUsingApp >= n
            }

            if earned {
                earnBadge(badge)
            }
        }
    }

    /// Get progress value (0.0 to 1.0) for a badge requirement
    func progress(for badge: Badge) -> Double {
        let settings = AppSettings.shared

        switch badge.requirement {
        case .currentStreak(let n):
            return min(Double(settings.currentStreak) / Double(n), 1.0)
        case .longestStreak(let n):
            return min(Double(settings.longestStreak) / Double(n), 1.0)
        case .totalCompletions(let n):
            return min(Double(settings.checkInTimes.count) / Double(n), 1.0)
        case .perfectWeeks(let n):
            return min(Double(perfectWeeksCount) / Double(n), 1.0)
        case .totalCheckIns(let n):
            return min(Double(settings.checkInTimes.count) / Double(n), 1.0)
        case .friendsAdded(let n):
            return min(Double(defaults.integer(forKey: "friendsCount")) / Double(n), 1.0)
        case .cheersGiven(let n):
            return min(Double(cheersGivenCount) / Double(n), 1.0)
        case .habitsCreated(let n):
            return min(Double(defaults.integer(forKey: "customHabitsCreated")) / Double(n), 1.0)
        case .daysUsingApp(let n):
            return min(Double(settings.daysUsingApp) / Double(n), 1.0)
        }
    }
}
