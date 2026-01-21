import SwiftUI

// MARK: - Date Helpers for Widget
struct WidgetDateHelpers {
    static let calendar = Calendar.current

    static func daysAgo(_ days: Int, from date: Date = Date()) -> Date {
        calendar.date(byAdding: .day, value: -days, to: date) ?? date
    }

    static func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    static func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }

    static func gridDates(weeks: Int = 52) -> [[Date]] {
        let today = calendar.startOfDay(for: Date())

        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        let endOfCurrentWeek = calendar.date(from: components) ?? today

        let startDate = calendar.date(byAdding: .weekOfYear, value: -(weeks - 1), to: endOfCurrentWeek)!

        var weeklyDates: [[Date]] = []
        var currentDate = startDate

        for _ in 0..<weeks {
            var week: [Date] = []
            for _ in 0..<7 {
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
}

// MARK: - Date Extension for Widget
extension Date {
    var widgetStartOfDay: Date {
        WidgetDateHelpers.startOfDay(self)
    }

    var widgetIsToday: Bool {
        WidgetDateHelpers.isToday(self)
    }
}

// MARK: - Grid Color Scheme for Widget
enum GridColorScheme: String, CaseIterable {
    case green = "green"
    case skyblue = "skyblue"
    case lavender = "lavender"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"
    case pink = "pink"

    /// Get the user's selected theme from UserDefaults
    static var userSelected: GridColorScheme {
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard
        if let themeName = defaults.string(forKey: "selectedTheme"),
           let theme = GridColorScheme(rawValue: themeName) {
            return theme
        }
        return .green
    }

    var colors: [Color] {
        switch self {
        case .green:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#0D3D1F"),
                Color(hex: "#1A7A3E"),
                Color(hex: "#28A745"),
                Color(hex: "#34C759")
            ]
        case .skyblue:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#0C3A5A"),
                Color(hex: "#1877B8"),
                Color(hex: "#3DA5E0"),
                Color(hex: "#5AC8FA")
            ]
        case .lavender:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#3D2E5C"),
                Color(hex: "#6B5B95"),
                Color(hex: "#9B8DC2"),
                Color(hex: "#BDB5D5")
            ]
        case .blue:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#0A3069"),
                Color(hex: "#0550AE"),
                Color(hex: "#218BFF"),
                Color(hex: "#58A6FF")
            ]
        case .purple:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#3D1F5C"),
                Color(hex: "#6E40C9"),
                Color(hex: "#8B5CF6"),
                Color(hex: "#A78BFA")
            ]
        case .orange:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#5C2D0E"),
                Color(hex: "#9A3412"),
                Color(hex: "#EA580C"),
                Color(hex: "#FB923C")
            ]
        case .pink:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#5C1F4A"),
                Color(hex: "#9D174D"),
                Color(hex: "#DB2777"),
                Color(hex: "#F472B6")
            ]
        }
    }

    func color(for level: Int, isDarkMode: Bool = true) -> Color {
        let clampedLevel = min(max(level, 0), 4)
        return colors[clampedLevel]
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
