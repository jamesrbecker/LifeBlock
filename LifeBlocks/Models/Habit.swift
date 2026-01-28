import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var isSystemHabit: Bool
    var healthKitType: String?
    var createdAt: Date
    var isActive: Bool
    var sortOrder: Int

    // Per-habit streak tracking
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var totalCompletions: Int

    // Habit Stacking
    var stackedAfterHabitId: UUID?  // The habit this one should follow
    var stackOrder: Int  // Order within a stack

    // Habit Scheduling (Premium) — which days of the week this habit is active
    // Stored as comma-separated day numbers: "1,2,3,4,5,6,7" (1=Sunday, 7=Saturday)
    // Empty string means "every day" (default)
    var scheduledDays: String

    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion]?

    init(
        name: String,
        icon: String = "checkmark.circle.fill",
        colorHex: String = "#30A14E",
        isSystemHabit: Bool = false,
        healthKitType: String? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isSystemHabit = isSystemHabit
        self.healthKitType = healthKitType
        self.createdAt = Date()
        self.isActive = true
        self.sortOrder = sortOrder
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCompletedDate = nil
        self.totalCompletions = 0
        self.stackedAfterHabitId = nil
        self.stackOrder = 0
        self.scheduledDays = ""  // Empty = every day
    }

    static let systemHabits: [(name: String, icon: String, healthKitType: String?)] = [
        ("Exercise", "figure.run", "workout"),
        ("Sleep", "bed.double.fill", "sleep"),
        ("Productivity", "briefcase.fill", nil),
        ("Learning", "book.fill", nil),
        ("Self-Care", "heart.fill", nil)
    ]

    static func createSystemHabits() -> [Habit] {
        systemHabits.enumerated().map { index, data in
            Habit(
                name: data.name,
                icon: data.icon,
                colorHex: "#30A14E",
                isSystemHabit: true,
                healthKitType: data.healthKitType,
                sortOrder: index
            )
        }
    }
}

@Model
final class HabitCompletion {
    var id: UUID
    var date: Date
    var completionLevel: Int // 0 = not done, 1 = partial, 2 = done
    var notes: String?
    var autoTracked: Bool

    var habit: Habit?

    init(date: Date, completionLevel: Int, autoTracked: Bool = false, notes: String? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.completionLevel = min(max(completionLevel, 0), 2)
        self.autoTracked = autoTracked
        self.notes = notes
    }
}

extension Habit {
    func completion(for date: Date) -> HabitCompletion? {
        let targetDate = Calendar.current.startOfDay(for: date)
        return completions?.first { Calendar.current.isDate($0.date, inSameDayAs: targetDate) }
    }

    func completionLevel(for date: Date) -> Int {
        completion(for: date)?.completionLevel ?? 0
    }

    // MARK: - Streak Management

    /// Updates the streak when a habit is completed
    func updateStreak(completedDate: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: completedDate)

        // Increment total completions
        totalCompletions += 1

        if let lastDate = lastCompletedDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysSinceLast = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

            if daysSinceLast == 1 {
                // Consecutive day - extend streak
                currentStreak += 1
            } else if daysSinceLast == 0 {
                // Same day - do nothing
                return
            } else {
                // Streak broken - start new
                currentStreak = 1
            }
        } else {
            // First completion
            currentStreak = 1
        }

        // Update longest streak
        longestStreak = max(longestStreak, currentStreak)
        lastCompletedDate = today
    }

    /// Checks if streak should be reset (called on app launch)
    func checkStreakStatus() {
        guard let lastDate = lastCompletedDate else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastDay = calendar.startOfDay(for: lastDate)
        let daysSinceLast = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        // If more than 1 day has passed without completion, reset streak
        if daysSinceLast > 1 {
            currentStreak = 0
        }
    }

    /// Returns streak status text
    var streakStatusText: String {
        if currentStreak == 0 {
            return "Start your streak!"
        } else if currentStreak == 1 {
            return "1 day"
        } else {
            return "\(currentStreak) days"
        }
    }

    /// Returns completion rate as percentage
    var completionRate: Double {
        let calendar = Calendar.current
        let daysSinceCreation = calendar.dateComponents([.day], from: createdAt, to: Date()).day ?? 1
        guard daysSinceCreation > 0 else { return 0 }
        return min(Double(totalCompletions) / Double(daysSinceCreation) * 100, 100)
    }

    // MARK: - Scheduling

    /// The set of weekday numbers this habit is scheduled for (1=Sunday, 7=Saturday)
    /// Empty set means every day
    var scheduledDayNumbers: Set<Int> {
        get {
            guard !scheduledDays.isEmpty else { return [] }
            return Set(scheduledDays.split(separator: ",").compactMap { Int($0) })
        }
        set {
            if newValue.isEmpty || newValue.count == 7 {
                scheduledDays = ""  // Every day
            } else {
                scheduledDays = newValue.sorted().map(String.init).joined(separator: ",")
            }
        }
    }

    /// Whether this habit is scheduled for every day
    var isEveryDay: Bool {
        scheduledDays.isEmpty
    }

    /// Whether this habit is scheduled for a given date
    func isScheduled(for date: Date) -> Bool {
        guard !scheduledDays.isEmpty else { return true }  // Every day
        let weekday = Calendar.current.component(.weekday, from: date)
        return scheduledDayNumbers.contains(weekday)
    }

    /// Short text describing the schedule (e.g., "Mon, Wed, Fri" or "Every day")
    var scheduleDisplayText: String {
        guard !scheduledDays.isEmpty else { return "Every day" }
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let days = scheduledDayNumbers.sorted()

        // Check for common patterns
        if days == [2, 3, 4, 5, 6] { return "Weekdays" }
        if days == [1, 7] { return "Weekends" }

        return days.map { dayNames[$0] }.joined(separator: ", ")
    }
}
