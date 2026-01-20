import Foundation
import SwiftData
import WidgetKit

@MainActor
final class DataManager: ObservableObject {
    static let shared = DataManager()

    private var modelContext: ModelContext?

    private init() {}

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Habits

    func createDefaultHabits() {
        guard let context = modelContext else { return }

        // Check if habits already exist
        let descriptor = FetchDescriptor<Habit>()
        guard let existingHabits = try? context.fetch(descriptor), existingHabits.isEmpty else {
            return
        }

        // Create system habits
        for habit in Habit.createSystemHabits() {
            context.insert(habit)
        }

        try? context.save()
    }

    func getActiveHabits() -> [Habit] {
        guard let context = modelContext else { return [] }

        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isActive },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Day Entries

    func getDayEntry(for date: Date) -> DayEntry? {
        guard let context = modelContext else { return nil }

        let targetDate = date.startOfDay
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.date == targetDate }
        )

        return try? context.fetch(descriptor).first
    }

    func getOrCreateDayEntry(for date: Date) -> DayEntry {
        if let existing = getDayEntry(for: date) {
            return existing
        }

        let entry = DayEntry(date: date)
        modelContext?.insert(entry)
        try? modelContext?.save()
        return entry
    }

    func getDayEntries(for range: ClosedRange<Date>) -> [DayEntry] {
        guard let context = modelContext else { return [] }

        let startDate = range.lowerBound.startOfDay
        let endDate = range.upperBound.startOfDay

        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.date >= startDate && $0.date <= endDate },
            sortBy: [SortDescriptor(\.date)]
        )

        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Statistics

    func getCurrentStreak() -> Int {
        guard let context = modelContext else { return 0 }

        var streak = 0
        var checkDate = Date().startOfDay

        while true {
            let descriptor = FetchDescriptor<DayEntry>(
                predicate: #Predicate { $0.date == checkDate && $0.checkedIn == true }
            )

            guard let entries = try? context.fetch(descriptor), !entries.isEmpty else {
                break
            }

            streak += 1
            checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }

    func getLongestStreak() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.checkedIn == true },
            sortBy: [SortDescriptor(\.date)]
        )

        guard let entries = try? context.fetch(descriptor) else { return 0 }

        var longestStreak = 0
        var currentStreak = 0
        var lastDate: Date?

        for entry in entries {
            if let last = lastDate {
                let daysDiff = Calendar.current.dateComponents([.day], from: last, to: entry.date).day ?? 0
                if daysDiff == 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }

            longestStreak = max(longestStreak, currentStreak)
            lastDate = entry.date
        }

        return longestStreak
    }

    func getTotalCheckIns() -> Int {
        guard let context = modelContext else { return 0 }

        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.checkedIn == true }
        )

        return (try? context.fetchCount(descriptor)) ?? 0
    }

    func getAverageScore(days: Int = 30) -> Double {
        guard let context = modelContext else { return 0 }

        let startDate = DateHelpers.daysAgo(days).startOfDay
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.date >= startDate && $0.checkedIn == true }
        )

        guard let entries = try? context.fetch(descriptor), !entries.isEmpty else { return 0 }

        let totalScore = entries.reduce(0) { $0 + $1.totalScore }
        return Double(totalScore) / Double(entries.count)
    }

    // MARK: - Widget Data Sync

    func syncWidgetData() {
        guard let context = modelContext else { return }

        // Get last 365 days of data
        let startDate = DateHelpers.daysAgo(365)
        let entries = getDayEntries(for: startDate...Date())

        // Convert to dictionary
        var scores: [String: Int] = [:]
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        for entry in entries {
            let dateString = dateFormatter.string(from: entry.date)
            scores[dateString] = entry.totalScore
        }

        // Save to shared UserDefaults
        if let data = try? JSONEncoder().encode(scores) {
            let defaults = UserDefaults(suiteName: "group.com.lifegrid.app")
            defaults?.set(data, forKey: "dayScores")
        }

        // Update current stats
        AppSettings.shared.currentStreak = getCurrentStreak()
        AppSettings.shared.longestStreak = getLongestStreak()

        if let todayEntry = getDayEntry(for: Date()) {
            AppSettings.shared.todayScore = todayEntry.totalScore
        }

        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Data Export

    func exportData() -> Data? {
        guard let context = modelContext else { return nil }

        struct ExportData: Codable {
            let exportDate: Date
            let habits: [ExportHabit]
            let entries: [ExportEntry]
        }

        struct ExportHabit: Codable {
            let name: String
            let icon: String
            let isSystem: Bool
        }

        struct ExportEntry: Codable {
            let date: Date
            let score: Int
            let completions: [String: Int]
        }

        let habitsDescriptor = FetchDescriptor<Habit>()
        let entriesDescriptor = FetchDescriptor<DayEntry>()

        guard let habits = try? context.fetch(habitsDescriptor),
              let entries = try? context.fetch(entriesDescriptor) else {
            return nil
        }

        let exportHabits = habits.map { ExportHabit(name: $0.name, icon: $0.icon, isSystem: $0.isSystemHabit) }

        let exportEntries = entries.map { entry -> ExportEntry in
            var completions: [String: Int] = [:]
            for habit in habits {
                completions[habit.name] = habit.completionLevel(for: entry.date)
            }
            return ExportEntry(date: entry.date, score: entry.totalScore, completions: completions)
        }

        let exportData = ExportData(
            exportDate: Date(),
            habits: exportHabits,
            entries: exportEntries
        )

        return try? JSONEncoder().encode(exportData)
    }
}
