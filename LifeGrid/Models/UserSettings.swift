import Foundation
import SwiftData

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
        self.selectedTheme = "green"
        self.createdAt = Date()
    }

    var reminderTimeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: reminderTime)
    }
}

// App-wide settings manager using UserDefaults for quick access
final class AppSettings {
    static let shared = AppSettings()

    private let defaults = UserDefaults(suiteName: "group.com.lifegrid.app") ?? .standard

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
                // Streak broken
                currentStreak = checkedInToday ? 1 : 0
            }
        } else if checkedInToday {
            currentStreak = 1
        }

        if checkedInToday {
            lastCheckInDate = today
            longestStreak = max(longestStreak, currentStreak)
        }
    }
}
