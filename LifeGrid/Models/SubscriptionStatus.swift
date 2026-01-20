import Foundation
import StoreKit

enum SubscriptionTier: String, CaseIterable {
    case free = "free"
    case premium = "premium"

    var maxHabits: Int {
        switch self {
        case .free: return 5
        case .premium: return .max
        }
    }

    var historyDays: Int {
        switch self {
        case .free: return 30
        case .premium: return 365
        }
    }

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
}

@MainActor
final class SubscriptionStatus: ObservableObject {
    static let shared = SubscriptionStatus()

    @Published var tier: SubscriptionTier = .free
    @Published var expirationDate: Date?
    @Published var isLoading: Bool = false

    // Product IDs - configure these in App Store Connect
    static let monthlyProductID = "com.lifegrid.premium.monthly"
    static let yearlyProductID = "com.lifegrid.premium.yearly"

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

    // Feature gating helpers
    func canAddMoreHabits(currentCount: Int) -> Bool {
        currentCount < tier.maxHabits
    }

    func isDateInHistory(_ date: Date) -> Bool {
        let daysAgo = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return daysAgo <= tier.historyDays
    }
}

// Pricing info for display
struct PricingInfo {
    static let monthlyPrice = "$4.99"
    static let yearlyPrice = "$39.99"
    static let yearlySavings = "Save 33%"

    static let features: [(icon: String, title: String, description: String)] = [
        ("infinity", "Unlimited Habits", "Track as many habits as you want"),
        ("rectangle.3.group", "All Widget Sizes", "Small, medium, and large widgets"),
        ("calendar", "Full Year History", "View your entire year at a glance"),
        ("chart.bar.fill", "Advanced Analytics", "Detailed insights and trends"),
        ("paintpalette.fill", "Custom Themes", "Personalize your experience"),
        ("square.and.arrow.up", "Export Data", "Download your data anytime")
    ]
}
