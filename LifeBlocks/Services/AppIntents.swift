import AppIntents
import SwiftUI

// MARK: - Check In Intent
/// Allows users to check in via Siri or Shortcuts

struct CheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Check In"
    static var description = IntentDescription("Log your daily check-in to LifeBlocks")

    static var openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let settings = AppSettings.shared

        // Update streak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = settings.lastCheckInDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            if !calendar.isDate(lastDay, inSameDayAs: today) {
                let daysSinceLast = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
                if daysSinceLast == 1 {
                    settings.currentStreak += 1
                } else {
                    settings.currentStreak = 1
                }
            }
        } else {
            settings.currentStreak = 1
        }

        settings.lastCheckInDate = today
        settings.longestStreak = max(settings.longestStreak, settings.currentStreak)

        return .result(dialog: "Checked in! You're on a \(settings.currentStreak)-day streak.")
    }
}

// MARK: - Get Streak Intent

struct GetStreakIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Streak"
    static var description = IntentDescription("Get your current streak from LifeBlocks")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let streak = AppSettings.shared.currentStreak
        let longest = AppSettings.shared.longestStreak

        if streak == 0 {
            return .result(dialog: "You don't have an active streak. Check in to start one!")
        } else if streak == 1 {
            return .result(dialog: "You're on day 1 of your streak. Your longest streak is \(longest) days.")
        } else {
            return .result(dialog: "You're on a \(streak)-day streak! Your longest is \(longest) days.")
        }
    }
}

// MARK: - Get Today's Score Intent

struct GetTodayScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Today's Score"
    static var description = IntentDescription("Get your activity score for today")

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let score = AppSettings.shared.todayScore

        let description: String
        switch score {
        case 0: description = "No activity yet"
        case 1: description = "Light activity"
        case 2: description = "Moderate activity"
        case 3: description = "Good activity"
        case 4: description = "Excellent activity"
        default: description = "Unknown"
        }

        return .result(dialog: "Today's score: \(score) out of 4 (\(description))")
    }
}

// MARK: - Log Habit Intent

struct LogHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Habit"
    static var description = IntentDescription("Mark a habit as complete")

    @Parameter(title: "Habit Name")
    var habitName: String

    @Parameter(title: "Completion Level", default: 2)
    var completionLevel: Int

    func perform() async throws -> some IntentResult & ProvidesDialog {
        // This would integrate with SwiftData in a real implementation
        // For now, return a confirmation
        let levelText: String
        switch completionLevel {
        case 0: levelText = "not done"
        case 1: levelText = "partially done"
        case 2: levelText = "done"
        default: levelText = "completed"
        }

        return .result(dialog: "Logged '\(habitName)' as \(levelText).")
    }
}

// MARK: - App Shortcuts Provider

struct LifeBlocksShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckInIntent(),
            phrases: [
                "Check in with \(.applicationName)",
                "Log my day in \(.applicationName)",
                "I'm done for the day in \(.applicationName)"
            ],
            shortTitle: "Check In",
            systemImageName: "checkmark.circle.fill"
        )

        AppShortcut(
            intent: GetStreakIntent(),
            phrases: [
                "What's my streak in \(.applicationName)",
                "How long is my streak in \(.applicationName)",
                "Get my \(.applicationName) streak"
            ],
            shortTitle: "Get Streak",
            systemImageName: "flame.fill"
        )

        AppShortcut(
            intent: GetTodayScoreIntent(),
            phrases: [
                "What's my score today in \(.applicationName)",
                "How am I doing today in \(.applicationName)",
                "Get today's score from \(.applicationName)"
            ],
            shortTitle: "Today's Score",
            systemImageName: "chart.bar.fill"
        )
    }
}

// MARK: - Focus Mode Integration

struct FocusModeHabitSuggestion {
    let focusMode: String
    let suggestedHabits: [String]

    static let suggestions: [FocusModeHabitSuggestion] = [
        FocusModeHabitSuggestion(
            focusMode: "Work",
            suggestedHabits: ["Deep Work", "Revenue Activity", "Code", "Sales Outreach"]
        ),
        FocusModeHabitSuggestion(
            focusMode: "Personal",
            suggestedHabits: ["Self-Care", "Exercise", "Meditate", "Read"]
        ),
        FocusModeHabitSuggestion(
            focusMode: "Fitness",
            suggestedHabits: ["Morning Workout", "Track Macros", "Recovery", "10K Steps"]
        ),
        FocusModeHabitSuggestion(
            focusMode: "Sleep",
            suggestedHabits: ["Sleep 8 Hours", "No Phone Morning", "Meditate"]
        ),
        FocusModeHabitSuggestion(
            focusMode: "Driving",
            suggestedHabits: [] // No habits while driving
        ),
        FocusModeHabitSuggestion(
            focusMode: "Reading",
            suggestedHabits: ["Read", "Learn", "Study Session"]
        )
    ]

    static func habitsFor(focusMode: String) -> [String] {
        suggestions.first { $0.focusMode.lowercased() == focusMode.lowercased() }?.suggestedHabits ?? []
    }
}
