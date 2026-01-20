import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct LifeBlocksEntry: TimelineEntry {
    let date: Date
    let dayScores: [Date: Int]
    let currentStreak: Int
    let todayScore: Int
}

// MARK: - Timeline Provider
struct LifeBlocksTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> LifeBlocksEntry {
        LifeBlocksEntry(
            date: Date(),
            dayScores: generateSampleData(),
            currentStreak: 7,
            todayScore: 3
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (LifeBlocksEntry) -> Void) {
        let entry = LifeBlocksEntry(
            date: Date(),
            dayScores: loadDayScores(),
            currentStreak: AppSettings.shared.currentStreak,
            todayScore: AppSettings.shared.todayScore
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LifeBlocksEntry>) -> Void) {
        let entry = LifeBlocksEntry(
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
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard

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
        return URL(string: "lifeblock://day/\(timestamp)")!
    }

    static func checkInURL() -> URL {
        return URL(string: "lifeblock://checkin")!
    }
}

// MARK: - Widget Configuration
struct LifeBlocksWidget: Widget {
    let kind: String = "LifeBlocksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeBlocksTimelineProvider()) { entry in
            LifeBlocksWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("LifeBlocks")
        .description("Track your daily habits with a GitHub-style grid.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Entry View
struct LifeBlocksWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: LifeBlocksEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Lock Screen Widgets

struct AccessoryCircularView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .font(.caption)
                Text("\(entry.currentStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
            }
        }
    }
}

struct AccessoryRectangularView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                    Text("\(entry.currentStreak) day streak")
                        .fontWeight(.semibold)
                }
                .font(.caption)

                Text("Today: \(scoreText(entry.todayScore))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Mini 7-day grid
            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { i in
                    let date = Calendar.current.date(byAdding: .day, value: -(6-i), to: Date())!
                    let score = entry.dayScores[Calendar.current.startOfDay(for: date)] ?? 0
                    RoundedRectangle(cornerRadius: 1)
                        .fill(score > 0 ? Color.primary : Color.primary.opacity(0.2))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }

    private func scoreText(_ score: Int) -> String {
        switch score {
        case 0: return "Not started"
        case 1: return "Light"
        case 2: return "Moderate"
        case 3: return "Good"
        case 4: return "Excellent"
        default: return "—"
        }
    }
}

struct AccessoryInlineView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
            Text("\(entry.currentStreak) day streak")
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 3
    )
}

#Preview(as: .systemMedium) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 3
    )
}

#Preview(as: .systemLarge) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 14,
        todayScore: 4
    )
}
