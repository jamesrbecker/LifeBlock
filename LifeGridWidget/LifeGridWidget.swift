import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct LifeGridEntry: TimelineEntry {
    let date: Date
    let dayScores: [Date: Int]
    let currentStreak: Int
    let todayScore: Int
}

// MARK: - Timeline Provider
struct LifeGridTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeGridEntry {
        LifeGridEntry(
            date: Date(),
            dayScores: generateSampleData(),
            currentStreak: 7,
            todayScore: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeGridEntry) -> Void) {
        let entry = LifeGridEntry(
            date: Date(),
            dayScores: loadDayScores(),
            currentStreak: AppSettings.shared.currentStreak,
            todayScore: AppSettings.shared.todayScore
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeGridEntry>) -> Void) {
        let entry = LifeGridEntry(
            date: Date(),
            dayScores: loadDayScores(),
            currentStreak: AppSettings.shared.currentStreak,
            todayScore: AppSettings.shared.todayScore
        )

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadDayScores() -> [Date: Int] {
        let defaults = UserDefaults(suiteName: "group.com.lifegrid.app") ?? .standard

        guard let data = defaults.data(forKey: "dayScores"),
              let scores = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        var result: [Date: Int] = [:]
        for (dateString, score) in scores {
            if let date = dateFormatter.date(from: dateString) {
                result[date] = score
            }
        }

        return result
    }

    private func generateSampleData() -> [Date: Int] {
        var data: [Date: Int] = [:]
        for i in 0..<365 {
            let date = Calendar.current.date(byAdding: .day, value: -i, to: Date())!
            data[Calendar.current.startOfDay(for: date)] = Int.random(in: 0...4)
        }
        return data
    }
}

// MARK: - Deep Link URL Scheme
struct DeepLink {
    static func url(for date: Date) -> URL {
        let timestamp = Int(date.timeIntervalSince1970)
        return URL(string: "lifegrid://day/\(timestamp)")!
    }

    static func checkInURL() -> URL {
        return URL(string: "lifegrid://checkin")!
    }
}

// MARK: - Widget Configuration
struct LifeGridWidget: Widget {
    let kind: String = "LifeGridWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeGridTimelineProvider()) { entry in
            LifeGridWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("LifeGrid")
        .description("Track your daily habits with a GitHub-style grid.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Entry View
struct LifeGridWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LifeGridEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    LifeGridWidget()
} timeline: {
    LifeGridEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 3
    )
}

#Preview(as: .systemMedium) {
    LifeGridWidget()
} timeline: {
    LifeGridEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 3
    )
}

#Preview(as: .systemLarge) {
    LifeGridWidget()
} timeline: {
    LifeGridEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 14,
        todayScore: 4
    )
}
