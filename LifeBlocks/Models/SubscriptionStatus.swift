import Foundation
import StoreKit
import SwiftUI

enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case premium = "premium"

    // MARK: - Habit Limits
    // Free: 3 custom habits (plus system habits)
    // Premium: Unlimited
    var maxCustomHabits: Int {
        switch self {
        case .free: return 3
        case .premium: return .max
        }
    }

    // MARK: - History Limits
    // Free: 7 days
    // Premium: Full year (365 days)
    var historyDays: Int {
        switch self {
        case .free: return 7
        case .premium: return 365
        }
    }

    // MARK: - Life Goals Limits
    // Free: 1 goal
    // Premium: Unlimited
    var maxLifeGoals: Int {
        switch self {
        case .free: return 1
        case .premium: return .max
        }
    }

    // MARK: - Feature Access
    var hasAllWidgets: Bool {
        self == .premium
    }

    var hasThemes: Bool {
        self == .premium
    }

    var hasAdvancedAnalytics: Bool {
        self == .premium
    }

    var canExportData: Bool {
        self == .premium
    }

    // Social features - Premium only
    var hasFriendsFeature: Bool {
        self == .premium
    }

    var hasLeaderboards: Bool {
        self == .premium
    }

    var hasChallenges: Bool {
        self == .premium
    }

    var hasShareCards: Bool {
        self == .premium
    }

    var hasMultiplePaths: Bool {
        self == .premium
    }
}

@MainActor
final class SubscriptionStatus: ObservableObject {
    static let shared = SubscriptionStatus()

    @Published var tier: SubscriptionTier = .free
    @Published var expirationDate: Date?
    @Published var isLoading: Bool = false

    // Product IDs - configure these in App Store Connect
    static let monthlyProductID = "com.lifeblock.premium.monthly"
    static let yearlyProductID = "com.lifeblock.premium.yearly"
    static let lifetimeProductID = "com.lifeblock.premium.lifetime"
    static let familyMonthlyProductID = "com.lifeblock.premium.family.monthly"
    static let familyProductID = "com.lifeblock.premium.family"
    static let familyLifetimeProductID = "com.lifeblock.premium.family.lifetime"

    private init() {
        // Check cached status
        tier = AppSettings.shared.isPremium ? .premium : .free
    }

    var isPremium: Bool {
        tier == .premium
    }

    func updateStatus(isPremium: Bool, expirationDate: Date? = nil) {
        self.tier = isPremium ? .premium : .free
        self.expirationDate = expirationDate
        AppSettings.shared.isPremium = isPremium
    }

    // MARK: - Feature Gating Helpers

    func canAddMoreHabits(currentCount: Int) -> Bool {
        currentCount < tier.maxCustomHabits
    }

    func canAddMoreGoals(currentCount: Int) -> Bool {
        currentCount < tier.maxLifeGoals
    }

    func isDateInHistory(_ date: Date) -> Bool {
        let daysAgo = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return daysAgo <= tier.historyDays
    }

    var canAccessLeaderboards: Bool {
        tier.hasLeaderboards
    }

    var canAccessChallenges: Bool {
        tier.hasChallenges
    }

    var canAccessShareCards: Bool {
        tier.hasShareCards
    }

    var canAccessFriends: Bool {
        tier.hasFriendsFeature
    }
}

// Pricing info for display
struct PricingInfo {
    // Individual
    static let monthlyPrice = "$1.99/month"
    static let yearlyPrice = "$19.99/year"
    static let lifetimePrice = "$49.99"
    // Family (up to 5)
    static let familyMonthlyPrice = "$4.99/month"
    static let familyYearlyPrice = "$39.99/year"
    static let familyLifetimePrice = "$79.99"
    // Savings
    static let yearlySavings = "Save 16%"
    static let familyYearlySavings = "Save 33%"

    static let features: [(icon: String, title: String, description: String)] = [
        ("infinity", "Unlimited Habits", "Track as many habits as you want"),
        ("star.fill", "Unlimited Life Goals", "Set short & long-term goals"),
        ("calendar", "Full Year History", "View your entire year at a glance"),
        ("person.2.fill", "Friends & Social", "Connect and compete with friends"),
        ("trophy.fill", "Leaderboards", "See how you rank globally"),
        ("flag.checkered", "Challenges", "Join challenges to stay motivated"),
        ("square.and.arrow.up", "Share Cards", "Share your progress beautifully"),
        ("rectangle.3.group", "All Widget Sizes", "Small, medium, and large widgets"),
        ("chart.bar.fill", "Advanced Analytics", "Detailed insights and trends"),
        ("paintpalette.fill", "Custom Themes", "Personalize your experience"),
        ("arrow.down.doc", "Export Data", "Download your data anytime")
    ]
}

