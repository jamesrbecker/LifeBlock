import Foundation

// Shared AppSettings for Widget access via App Groups
final class AppSettings {
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
}
