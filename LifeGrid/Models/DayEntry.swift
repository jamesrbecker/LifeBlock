import Foundation
import SwiftData

@Model
final class DayEntry {
    var id: UUID
    var date: Date
    var totalScore: Int // 0-4 scale like GitHub
    var checkedIn: Bool
    var checkedInAt: Date?

    init(date: Date) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.totalScore = 0
        self.checkedIn = false
        self.checkedInAt = nil
    }

    var intensityLevel: IntensityLevel {
        IntensityLevel(rawValue: min(totalScore, 4)) ?? .none
    }
}

enum IntensityLevel: Int, CaseIterable {
    case none = 0
    case light = 1
    case medium = 2
    case high = 3
    case maximum = 4

    var description: String {
        switch self {
        case .none: return "No activity"
        case .light: return "Light activity"
        case .medium: return "Moderate activity"
        case .high: return "High activity"
        case .maximum: return "Maximum activity"
        }
    }
}

// Utility to calculate day score from habit completions
extension DayEntry {
    static func calculateScore(from completions: [HabitCompletion], totalHabits: Int) -> Int {
        guard totalHabits > 0 else { return 0 }

        let totalPoints = completions.reduce(0) { $0 + $1.completionLevel }
        let maxPoints = totalHabits * 2 // Each habit can score 0, 1, or 2

        let percentage = Double(totalPoints) / Double(maxPoints)

        switch percentage {
        case 0:
            return 0
        case 0.01..<0.25:
            return 1
        case 0.25..<0.50:
            return 2
        case 0.50..<0.75:
            return 3
        default:
            return 4
        }
    }
}
