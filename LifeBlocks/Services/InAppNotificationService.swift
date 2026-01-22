import Foundation
import SwiftUI

// MARK: - In-App Notification Model

struct InAppNotification: Identifiable, Codable {
    let id: UUID
    let title: String
    let message: String
    let type: NotificationType
    let timestamp: Date
    var isRead: Bool
    var actionURL: String?

    enum NotificationType: String, Codable {
        case streak          // Streak milestones
        case achievement     // Achievements unlocked
        case social          // Friend activity, cheers
        case reminder        // Check-in reminders
        case system          // App updates, tips
        case challenge       // Challenge updates
    }

    init(
        id: UUID = UUID(),
        title: String,
        message: String,
        type: NotificationType,
        timestamp: Date = Date(),
        isRead: Bool = false,
        actionURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.actionURL = actionURL
    }

    var icon: String {
        switch type {
        case .streak: return "flame.fill"
        case .achievement: return "trophy.fill"
        case .social: return "person.2.fill"
        case .reminder: return "bell.fill"
        case .system: return "info.circle.fill"
        case .challenge: return "flag.checkered"
        }
    }

    var iconColor: Color {
        switch type {
        case .streak: return .orange
        case .achievement: return .yellow
        case .social: return Color.accentGreen
        case .reminder: return .blue
        case .system: return .gray
        case .challenge: return .purple
        }
    }
}

// MARK: - In-App Notification Service

@MainActor
final class InAppNotificationService: ObservableObject {
    static let shared = InAppNotificationService()

    @Published var notifications: [InAppNotification] = []
    @Published var unreadCount: Int = 0

    private let storageKey = "inAppNotifications"
    private let maxNotifications = 50

    private init() {
        loadNotifications()
    }

    // MARK: - Add Notifications

    func addNotification(_ notification: InAppNotification) {
        notifications.insert(notification, at: 0)

        // Trim old notifications
        if notifications.count > maxNotifications {
            notifications = Array(notifications.prefix(maxNotifications))
        }

        updateUnreadCount()
        saveNotifications()
    }

    func addStreakMilestone(streak: Int) {
        let title: String
        let message: String

        switch streak {
        case 7:
            title = "🔥 1 Week Streak!"
            message = "You've checked in for 7 days straight. Keep it going!"
        case 14:
            title = "🔥 2 Week Streak!"
            message = "Two weeks of consistency. You're building a real habit!"
        case 21:
            title = "🔥 3 Week Streak!"
            message = "21 days - they say that's how long it takes to form a habit!"
        case 30:
            title = "🎉 1 Month Streak!"
            message = "A full month of daily check-ins. Incredible dedication!"
        case 50:
            title = "⭐ 50 Day Streak!"
            message = "Halfway to 100! Nothing can stop you now."
        case 100:
            title = "🏆 100 Day Streak!"
            message = "Triple digits! You're a habit master."
        case 365:
            title = "👑 1 Year Streak!"
            message = "One full year of daily check-ins. Legendary!"
        default:
            if streak % 100 == 0 {
                title = "🏆 \(streak) Day Streak!"
                message = "Another century of consistency. Amazing!"
            } else {
                return // Don't add notification for non-milestone streaks
            }
        }

        let notification = InAppNotification(
            title: title,
            message: message,
            type: .streak
        )
        addNotification(notification)
    }

    func addCheerReceived(fromName: String, cheerType: String) {
        let notification = InAppNotification(
            title: "🎉 \(fromName) sent you a cheer!",
            message: cheerType,
            type: .social,
            actionURL: "lifeblock://friends"
        )
        addNotification(notification)
    }

    func addFriendRequest(fromName: String) {
        let notification = InAppNotification(
            title: "👋 New Friend Request",
            message: "\(fromName) wants to be your friend",
            type: .social,
            actionURL: "lifeblock://friends"
        )
        addNotification(notification)
    }

    func addChallengeUpdate(title: String, message: String) {
        let notification = InAppNotification(
            title: title,
            message: message,
            type: .challenge,
            actionURL: "lifeblock://challenges"
        )
        addNotification(notification)
    }

    func addSystemNotification(title: String, message: String) {
        let notification = InAppNotification(
            title: title,
            message: message,
            type: .system
        )
        addNotification(notification)
    }

    func addWelcomeNotification() {
        let notification = InAppNotification(
            title: "👋 Welcome to Blocks!",
            message: "Start building your habits one day at a time. Check in daily to see your progress grow.",
            type: .system
        )
        addNotification(notification)
    }

    // MARK: - Read/Unread Management

    func markAsRead(_ notification: InAppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
            updateUnreadCount()
            saveNotifications()
        }
    }

    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
        updateUnreadCount()
        saveNotifications()
    }

    func deleteNotification(_ notification: InAppNotification) {
        notifications.removeAll { $0.id == notification.id }
        updateUnreadCount()
        saveNotifications()
    }

    func clearAll() {
        notifications.removeAll()
        updateUnreadCount()
        saveNotifications()
    }

    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }

    // MARK: - Persistence

    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func loadNotifications() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([InAppNotification].self, from: data) {
            notifications = decoded
            updateUnreadCount()
        }
    }
}
