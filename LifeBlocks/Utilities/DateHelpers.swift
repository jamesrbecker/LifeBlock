import Foundation

struct DateHelpers {
    static let calendar = Calendar.current

    // Get all dates for the contribution grid (52 weeks)
    static func gridDates(weeks: Int = 52, weekStartsOnMonday: Bool = true) -> [[Date]] {
        let today = calendar.startOfDay(for: Date())

        // Find the start of the current week
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = weekStartsOnMonday ? 2 : 1 // Monday = 2, Sunday = 1
        let endOfCurrentWeek = calendar.date(from: components) ?? today

        // Calculate start date (52 weeks ago from the start of current week)
        let startDate = calendar.date(byAdding: .weekOfYear, value: -(weeks - 1), to: endOfCurrentWeek)!

        var weeklyDates: [[Date]] = []
        var currentDate = startDate

        for _ in 0..<weeks {
            var week: [Date] = []
            for _ in 0..<7 {
                // Only include dates up to today
                if currentDate <= today {
                    week.append(currentDate)
                }
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
            if !week.isEmpty {
                weeklyDates.append(week)
            }
        }

        return weeklyDates
    }

    // Get month labels for the grid
    static func monthLabels(for dates: [[Date]]) -> [(month: String, weekIndex: Int)] {
        var labels: [(String, Int)] = []
        var lastMonth = -1
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"

        for (weekIndex, week) in dates.enumerated() {
            guard let firstDay = week.first else { continue }
            let month = calendar.component(.month, from: firstDay)
            if month != lastMonth {
                labels.append((formatter.string(from: firstDay), weekIndex))
                lastMonth = month
            }
        }

        return labels
    }

    // Get weekday labels
    static func weekdayLabels(weekStartsOnMonday: Bool = true) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        if weekStartsOnMonday {
            return ["Mon", "", "Wed", "", "Fri", "", ""]
        } else {
            return ["", "Mon", "", "Wed", "", "Fri", ""]
        }
    }

    // Format date for display
    static func formatDate(_ date: Date, style: DateFormatStyle = .medium) -> String {
        let formatter = DateFormatter()
        switch style {
        case .short:
            formatter.dateFormat = "MMM d"
        case .medium:
            formatter.dateFormat = "EEEE, MMM d"
        case .long:
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
        case .relative:
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .medium
        }
        return formatter.string(from: date)
    }

    // Check if date is today
    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    // Days between two dates
    static func daysBetween(_ start: Date, _ end: Date) -> Int {
        calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    // Start of day
    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    // Get date for specific days ago
    static func daysAgo(_ days: Int, from date: Date = Date()) -> Date {
        calendar.date(byAdding: .day, value: -days, to: date) ?? date
    }

    // Check if two dates are the same day
    static func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
}

enum DateFormatStyle {
    case short
    case medium
    case long
    case relative
}

// Extension for easier date handling
extension Date {
    var startOfDay: Date {
        DateHelpers.startOfDay(self)
    }

    var isToday: Bool {
        DateHelpers.isToday(self)
    }

    func daysUntil(_ date: Date) -> Int {
        DateHelpers.daysBetween(self, date)
    }

    func isSameDay(as other: Date) -> Bool {
        DateHelpers.isSameDay(self, other)
    }
}
