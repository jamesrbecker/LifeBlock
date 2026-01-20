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
}
