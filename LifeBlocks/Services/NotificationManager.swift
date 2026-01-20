import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var pendingNotifications: [UNNotificationRequest] = []

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    // MARK: - Daily Reminder

    func scheduleDailyReminder(at time: Date) async {
        if !isAuthorized {
            _ = await requestAuthorization()
        }
        guard isAuthorized else { return }

        // Remove existing daily reminders
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])

        let content = UNMutableNotificationContent()
        content.title = "Time to check in!"
        content.body = randomReminderMessage()
        content.sound = .default
        content.badge = 1

        // Create trigger for specified time, repeating daily
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-checkin",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
            print("Daily reminder scheduled for \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0)")
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    func cancelDailyReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-checkin"])
    }

    // MARK: - Streak Reminders

    func scheduleStreakReminder(currentStreak: Int) async {
        guard isAuthorized, currentStreak > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Don't break your streak!"
        content.body = "You're on a \(currentStreak)-day streak. Check in to keep it going!"
        content.sound = .default

        // Schedule for 9 PM if not checked in
        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: "streak-reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Error scheduling streak reminder: \(error)")
        }
    }

    func cancelStreakReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["streak-reminder"])
    }

    // MARK: - Milestone Notifications

    func sendMilestoneNotification(streak: Int) {
        guard isAuthorized else { return }

        let milestones = [7, 14, 21, 30, 50, 100, 365]
        guard milestones.contains(streak) else { return }

        let content = UNMutableNotificationContent()
        content.title = milestoneTitle(for: streak)
        content.body = milestoneMessage(for: streak)
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "milestone-\(streak)",
            content: content,
            trigger: nil // Immediate
        )

        notificationCenter.add(request)
    }

    // MARK: - Helper Methods

    private func randomReminderMessage() -> String {
        let messages = [
            "How did your day go? Log your habits now.",
            "Take a moment to reflect on today's progress.",
            "Your future self will thank you for tracking today.",
            "Small daily actions lead to big results.",
            "Ready to color in today's square?",
            "What did you accomplish today?",
            "Let's see how today went!",
            "Time to log your daily wins.",
        ]
        return messages.randomElement() ?? messages[0]
    }

    // MARK: - Daily Motivational Messages (Forward-Looking Only)

    func scheduleMorningMotivation(at hour: Int = 8) async {
        guard isAuthorized else { return }

        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["morning-motivation"])

        let content = UNMutableNotificationContent()
        content.title = morningMotivationTitle()
        content.body = morningMotivationMessage()
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "morning-motivation",
            content: content,
            trigger: trigger
        )

        try? await notificationCenter.add(request)
    }

    private func morningMotivationTitle() -> String {
        let streak = AppSettings.shared.currentStreak
        let titles = [
            "Today is full of possibilities",
            "Make today count",
            "A fresh start awaits",
            "Your best day starts now",
            "Rise and shine"
        ]

        if streak >= 7 {
            return "Day \(streak + 1) of your journey"
        }
        return titles.randomElement() ?? titles[0]
    }

    private func morningMotivationMessage() -> String {
        let streak = AppSettings.shared.currentStreak

        // Forward-looking, positive messages - NEVER about the past or mortality
        let motivationalMessages = [
            "Yesterday is gone. Today's choices shape tomorrow. What will you accomplish?",
            "The only moment that matters is now. Make it a level 4 day.",
            "Every green square on your grid started with a single decision today.",
            "Imagine looking back at a year of daily wins. It starts with this moment.",
            "Your future grid is waiting to be filled. Today is where you begin.",
            "One year from now, you'll be glad you started today.",
            "The best time to start was yesterday. The second best time is right now.",
            "Your potential has no expiration date. Today is your chance.",
            "Small actions today create the person you become tomorrow.",
            "Picture your grid in 30 days - each green square is a promise you kept to yourself."
        ]

        // Personalized based on current state
        if streak >= 30 {
            return "A month of consistency! Keep building the life you want, one day at a time."
        } else if streak >= 7 {
            return "You've shown up for \(streak) days straight. Today's another chance to strengthen that foundation."
        } else if streak >= 1 {
            return "You checked in yesterday. Chain another day and watch momentum build."
        }

        return motivationalMessages.randomElement() ?? motivationalMessages[0]
    }

    // Preview message showing what their stats COULD look like (positive projection)
    static func generateFuturePreview(currentStreak: Int) -> (title: String, message: String) {
        let title = "Your potential"
        let projectedStreak30 = currentStreak + 30
        let projectedStreak90 = currentStreak + 90

        let message = """
        If you show up every day:
        • In 30 days: \(projectedStreak30)-day streak
        • In 90 days: \(projectedStreak90)-day streak
        • In 1 year: A full grid of progress

        Every day you get to decide. Today is your day.
        """

        return (title, message)
    }

    private func milestoneTitle(for streak: Int) -> String {
        switch streak {
        case 7: return "1 Week Streak!"
        case 14: return "2 Week Streak!"
        case 21: return "3 Weeks Strong!"
        case 30: return "1 Month Streak!"
        case 50: return "50 Day Milestone!"
        case 100: return "100 Days!"
        case 365: return "1 Year Streak!"
        default: return "Milestone Reached!"
        }
    }

    private func milestoneMessage(for streak: Int) -> String {
        switch streak {
        case 7: return "You've built a habit! Keep it going."
        case 14: return "Two weeks of consistency. You're on fire!"
        case 21: return "Research says it takes 21 days to form a habit. You did it!"
        case 30: return "A full month of dedication. Incredible!"
        case 50: return "Halfway to 100. Nothing can stop you now!"
        case 100: return "Triple digits! You're a habit master."
        case 365: return "One full year of daily check-ins. Legendary!"
        default: return "Keep up the amazing work!"
        }
    }

    // MARK: - Badge Management

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    func getPendingNotifications() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        pendingNotifications = requests
    }
}

// MARK: - Notification Categories for Actions

extension NotificationManager {
    func registerNotificationCategories() {
        // Quick check-in action
        let checkInAction = UNNotificationAction(
            identifier: "CHECK_IN",
            title: "Check In Now",
            options: [.foreground]
        )

        // Snooze action
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind in 1 hour",
            options: []
        )

        let category = UNNotificationCategory(
            identifier: "DAILY_CHECKIN",
            actions: [checkInAction, snoozeAction],
            intentIdentifiers: [],
            options: []
        )

        notificationCenter.setNotificationCategories([category])
    }
}

// MARK: - Notification Settings View

import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("reminderEnabled") private var reminderEnabled = false
    @AppStorage("reminderHour") private var reminderHour = 9
    @AppStorage("reminderMinute") private var reminderMinute = 0
    @AppStorage("morningMotivationEnabled") private var morningMotivationEnabled = false
    @AppStorage("streakReminderEnabled") private var streakReminderEnabled = true

    @State private var reminderTime = Date()

    var body: some View {
        List {
            Section {
                Toggle(isOn: $reminderEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Daily Reminder")
                            Text("Get reminded to check in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.orange)
                    }
                }
                .onChange(of: reminderEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.scheduleDailyReminder(at: reminderTime)
                        }
                    } else {
                        notificationManager.cancelDailyReminder()
                    }
                }

                if reminderEnabled {
                    DatePicker(
                        "Reminder Time",
                        selection: $reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: reminderTime) { _, newValue in
                        reminderHour = Calendar.current.component(.hour, from: newValue)
                        reminderMinute = Calendar.current.component(.minute, from: newValue)
                        Task {
                            await notificationManager.scheduleDailyReminder(at: newValue)
                        }
                    }
                }
            }

            Section {
                Toggle(isOn: $morningMotivationEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Morning Motivation")
                            Text("Start your day with inspiration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "sunrise.fill")
                            .foregroundStyle(.yellow)
                    }
                }
                .onChange(of: morningMotivationEnabled) { _, newValue in
                    if newValue {
                        Task {
                            await notificationManager.scheduleMorningMotivation(at: 8)
                        }
                    } else {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(
                            withIdentifiers: ["morning-motivation"]
                        )
                    }
                }

                Toggle(isOn: $streakReminderEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("Streak Reminder")
                            Text("Evening reminder if you haven't checked in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.red)
                    }
                }
            }

            if !notificationManager.isAuthorized {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Notifications Disabled", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)

                        Text("Enable notifications in Settings to receive reminders.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("How Reminders Work", systemImage: "info.circle")
                        .font(.headline)

                    Text("Daily reminders help you stay consistent. Streak reminders notify you at 9 PM if you haven't checked in yet that day.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Notifications")
        .onAppear {
            // Load saved time
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            if let date = Calendar.current.date(from: components) {
                reminderTime = date
            }

            Task {
                await notificationManager.checkAuthorizationStatus()
            }
        }
    }
}

#Preview {
    NavigationView {
        NotificationSettingsView()
    }
    .preferredColorScheme(.dark)
}
