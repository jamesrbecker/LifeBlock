import SwiftUI
import SwiftData

// MARK: - App Notification Model
/// In-app notifications that persist in the notification center

@Model
final class AppNotification {
    var id: UUID = UUID()
    var title: String
    var message: String
    var type: NotificationType
    var createdAt: Date = Date()
    var isRead: Bool = false
    var actionURL: String?
    var metadata: [String: String]?

    enum NotificationType: String, Codable {
        case streakMilestone = "streak"
        case achievement = "achievement"
        case friendRequest = "friend_request"
        case cheer = "cheer"
        case challenge = "challenge"
        case reminder = "reminder"
        case weeklyReview = "weekly_review"
        case tip = "tip"
        case system = "system"

        var icon: String {
            switch self {
            case .streakMilestone: return "flame.fill"
            case .achievement: return "trophy.fill"
            case .friendRequest: return "person.badge.plus"
            case .cheer: return "hand.thumbsup.fill"
            case .challenge: return "flag.checkered"
            case .reminder: return "bell.fill"
            case .weeklyReview: return "calendar.badge.clock"
            case .tip: return "lightbulb.fill"
            case .system: return "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .streakMilestone: return .orange
            case .achievement: return .yellow
            case .friendRequest: return .blue
            case .cheer: return .green
            case .challenge: return .purple
            case .reminder: return .cyan
            case .weeklyReview: return .indigo
            case .tip: return .mint
            case .system: return .gray
            }
        }
    }

    init(
        title: String,
        message: String,
        type: NotificationType,
        actionURL: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.actionURL = actionURL
        self.metadata = metadata
    }
}

// MARK: - Notification Service
/// Handles creating and managing in-app notifications

@MainActor
class NotificationCenterService: ObservableObject {
    static let shared = NotificationCenterService()

    @Published var unreadCount: Int = 0

    private var modelContext: ModelContext?

    func configure(with context: ModelContext) {
        self.modelContext = context
        updateUnreadCount()
    }

    func updateUnreadCount() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { !$0.isRead }
        )

        do {
            let count = try context.fetchCount(descriptor)
            unreadCount = count
        } catch {
            print("Error fetching unread count: \(error)")
        }
    }

    func addNotification(
        title: String,
        message: String,
        type: AppNotification.NotificationType,
        actionURL: String? = nil,
        metadata: [String: String]? = nil
    ) {
        guard let context = modelContext else { return }

        let notification = AppNotification(
            title: title,
            message: message,
            type: type,
            actionURL: actionURL,
            metadata: metadata
        )

        context.insert(notification)
        try? context.save()
        updateUnreadCount()
    }

    func markAsRead(_ notification: AppNotification) {
        notification.isRead = true
        try? modelContext?.save()
        updateUnreadCount()
    }

    func markAllAsRead() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { !$0.isRead }
        )

        do {
            let unread = try context.fetch(descriptor)
            for notification in unread {
                notification.isRead = true
            }
            try context.save()
            updateUnreadCount()
        } catch {
            print("Error marking all as read: \(error)")
        }
    }

    func deleteOldNotifications(olderThan days: Int = 30) {
        guard let context = modelContext else { return }

        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date())!

        let descriptor = FetchDescriptor<AppNotification>(
            predicate: #Predicate { $0.createdAt < cutoffDate }
        )

        do {
            let old = try context.fetch(descriptor)
            for notification in old {
                context.delete(notification)
            }
            try context.save()
        } catch {
            print("Error deleting old notifications: \(error)")
        }
    }

    // MARK: - Convenience Methods for Common Notifications

    func notifyStreakMilestone(_ days: Int) {
        let messages: [Int: (String, String)] = [
            7: ("1 Week Streak!", "You've been consistent for a whole week. Keep it up!"),
            14: ("2 Week Streak!", "Two weeks strong! You're building real momentum."),
            21: ("21 Day Streak!", "Habits form around 21 days. You're officially on track!"),
            30: ("1 Month Streak!", "A full month of consistency. You're crushing it!"),
            50: ("50 Day Streak!", "Halfway to 100! Your dedication is inspiring."),
            100: ("100 Day Streak!", "Triple digits! You've built something incredible."),
            365: ("1 Year Streak!", "A full year of daily progress. Legendary!")
        ]

        if let (title, message) = messages[days] {
            addNotification(
                title: title,
                message: message,
                type: .streakMilestone,
                actionURL: "lifeblock://stats"
            )
        }
    }

    func notifyFriendRequest(from name: String) {
        addNotification(
            title: "New Friend Request",
            message: "\(name) wants to connect with you!",
            type: .friendRequest,
            actionURL: "lifeblock://friends"
        )
    }

    func notifyCheer(from name: String, emoji: String) {
        addNotification(
            title: "You received a cheer!",
            message: "\(name) sent you \(emoji)",
            type: .cheer,
            actionURL: "lifeblock://friends"
        )
    }

    func notifyWeeklyReview(checkIns: Int, averageScore: Double) {
        addNotification(
            title: "Weekly Summary Ready",
            message: "You checked in \(checkIns) times with an average score of \(String(format: "%.1f", averageScore)). Tap to see your full report.",
            type: .weeklyReview,
            actionURL: "lifeblock://weekly"
        )
    }

    func addTip(_ title: String, _ message: String) {
        addNotification(
            title: title,
            message: message,
            type: .tip
        )
    }
}

// MARK: - Notification Center View
/// Shows in-app notification history

struct NotificationCenterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \AppNotification.createdAt, order: .reverse) private var notifications: [AppNotification]
    @StateObject private var service = NotificationCenterService.shared

    var body: some View {
        NavigationStack {
            Group {
                if notifications.isEmpty {
                    emptyState
                } else {
                    notificationList
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }

                if !notifications.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                service.markAllAsRead()
                            } label: {
                                Label("Mark All as Read", systemImage: "checkmark.circle")
                            }

                            Button(role: .destructive) {
                                clearAllNotifications()
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .onAppear {
                service.configure(with: modelContext)
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Notifications", systemImage: "bell.slash")
        } description: {
            Text("You're all caught up! Notifications about your progress, friends, and achievements will appear here.")
        }
    }

    private var notificationList: some View {
        List {
            // Unread section
            let unread = notifications.filter { !$0.isRead }
            if !unread.isEmpty {
                Section("New") {
                    ForEach(unread) { notification in
                        NotificationRow(notification: notification)
                            .onTapGesture {
                                handleTap(notification)
                            }
                    }
                    .onDelete { indexSet in
                        deleteNotifications(at: indexSet, from: unread)
                    }
                }
            }

            // Read section
            let read = notifications.filter { $0.isRead }
            if !read.isEmpty {
                Section("Earlier") {
                    ForEach(read) { notification in
                        NotificationRow(notification: notification)
                            .onTapGesture {
                                handleTap(notification)
                            }
                    }
                    .onDelete { indexSet in
                        deleteNotifications(at: indexSet, from: read)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func handleTap(_ notification: AppNotification) {
        if !notification.isRead {
            service.markAsRead(notification)
        }

        if let urlString = notification.actionURL,
           let url = URL(string: urlString) {
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                UIApplication.shared.open(url)
            }
        }
    }

    private func deleteNotifications(at offsets: IndexSet, from source: [AppNotification]) {
        for index in offsets {
            let notification = source[index]
            modelContext.delete(notification)
        }
        try? modelContext.save()
        service.updateUnreadCount()
    }

    private func clearAllNotifications() {
        for notification in notifications {
            modelContext.delete(notification)
        }
        try? modelContext.save()
        service.updateUnreadCount()
    }
}

// MARK: - Notification Row

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: notification.type.icon)
                    .font(.body)
                    .foregroundStyle(notification.type.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.subheadline)
                        .fontWeight(notification.isRead ? .regular : .semibold)
                        .foregroundStyle(notification.isRead ? Color.secondaryText : Color.primaryText)

                    Spacer()

                    Text(timeAgo(notification.createdAt))
                        .font(.caption2)
                        .foregroundStyle(Color.tertiaryText)
                }

                Text(notification.message)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(2)
            }

            if !notification.isRead {
                Circle()
                    .fill(Color.accentGreen)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func timeAgo(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Notification Bell Button

struct NotificationBellButton: View {
    @StateObject private var service = NotificationCenterService.shared
    @State private var showingNotifications = false

    var body: some View {
        Button {
            HapticManager.shared.lightTap()
            showingNotifications = true
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .foregroundStyle(Color.secondaryText)

                if service.unreadCount > 0 {
                    Text(service.unreadCount > 99 ? "99+" : "\(service.unreadCount)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.red)
                        .clipShape(Capsule())
                        .offset(x: 6, y: -6)
                }
            }
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationCenterView()
        }
    }
}
