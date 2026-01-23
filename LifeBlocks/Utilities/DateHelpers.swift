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

    /// Contribution grid: 80 days past + current week (including future days)
    /// Current week is on the far right with today highlighted
    static func contributionGridDates(pastDays: Int = 80, futureDays: Int = 10) -> [[Date]] {
        let today = calendar.startOfDay(for: Date())

        // Find what day of the week today is (1 = Sunday, 2 = Monday, etc.)
        let weekday = calendar.component(.weekday, from: today)
        // Calculate days until end of week (Saturday = 7)
        // For Monday start: Monday = 2, so days from Monday to Sunday = 7 days
        let mondayWeekday = 2
        let adjustedWeekday = weekday == 1 ? 8 : weekday // Sunday wraps to 8
        let daysFromMonday = adjustedWeekday - mondayWeekday
        let daysUntilSunday = 6 - daysFromMonday

        // Calculate end date (end of current week + remaining future days)
        let endOfCurrentWeek = calendar.date(byAdding: .day, value: daysUntilSunday, to: today)!
        let remainingFutureDays = max(0, futureDays - daysUntilSunday - 1)
        let endDate = calendar.date(byAdding: .day, value: remainingFutureDays, to: endOfCurrentWeek)!

        // Total days we need
        let totalDays = pastDays + futureDays
        let totalWeeks = (totalDays + 6) / 7

        // Start date - align to Monday
        let startDate = calendar.date(byAdding: .day, value: -(pastDays - 1), to: today)!
        // Adjust to previous Monday
        let startWeekday = calendar.component(.weekday, from: startDate)
        let adjustedStartWeekday = startWeekday == 1 ? 8 : startWeekday
        let daysToSubtract = adjustedStartWeekday - mondayWeekday
        let alignedStartDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: startDate)!

        var weeklyDates: [[Date]] = []
        var currentDate = alignedStartDate

        while currentDate <= endDate {
            var week: [Date] = []
            for _ in 0..<7 {
                if currentDate <= endDate {
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

    /// Check if a date is in the future
    static func isFuture(_ date: Date) -> Bool {
        let today = calendar.startOfDay(for: Date())
        return date > today
    }

    /// Check if a date is in the current week
    static func isCurrentWeek(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
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
