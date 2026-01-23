import WidgetKit
import SwiftUI

// MARK: - StandBy Widget for iOS 17
/// Optimized widget for StandBy mode (nightstand display)

struct StandByWidget: Widget {
    let kind: String = "LifeBlocksStandByWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeBlocksTimelineProvider()) { entry in
            StandByWidgetView(entry: entry)
                .containerBackground(Color(hex: "#0D1117"), for: .widget)
        }
        .configurationDisplayName("LifeBlocks StandBy")
        .description("View your streak and activity at a glance in StandBy mode.")
        .supportedFamilies([.systemSmall, .systemMedium])
        // StandBy uses regular widget families but displays them larger
        .contentMarginsDisabled()
    }
}

// MARK: - StandBy Widget View

struct StandByWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.showsWidgetContainerBackground) var showsBackground
    var entry: LifeBlocksEntry

    var body: some View {
        switch family {
        case .systemSmall:
            StandBySmallView(entry: entry)
        case .systemMedium:
            StandByMediumView(entry: entry)
        default:
            StandBySmallView(entry: entry)
        }
    }
}

// MARK: - StandBy Small View (Circular focus on streak)

struct StandBySmallView: View {
    let entry: LifeBlocksEntry
    let colorScheme = GridColorScheme.green

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 8) {
                // Main streak circle
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 8)

                    // Progress ring (based on streak progress toward goal)
                    Circle()
                        .trim(from: 0, to: streakProgress)
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.15))
                            .foregroundStyle(.orange)

                        Text("\(entry.currentStreak)")
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.25, weight: .bold, design: .rounded))

                        Text("days")
                            .font(.system(size: min(geo.size.width, geo.size.height) * 0.08))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: min(geo.size.width, geo.size.height) * 0.7,
                       height: min(geo.size.width, geo.size.height) * 0.7)

                // Today's score indicator
                HStack(spacing: 4) {
                    ForEach(0..<4) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(level < entry.todayScore ? colorScheme.color(for: entry.todayScore, isDarkMode: true) : Color.gray.opacity(0.3))
                            .frame(width: 12, height: 6)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .widgetURL(DeepLink.checkInURL())
    }

    private var streakProgress: Double {
        // Progress toward common streak milestones (7, 14, 21, 30, etc.)
        let milestones = [7, 14, 21, 30, 60, 90, 180, 365]
        let nextMilestone = milestones.first { $0 > entry.currentStreak } ?? 365
        let previousMilestone = milestones.last { $0 <= entry.currentStreak } ?? 0

        let progress = Double(entry.currentStreak - previousMilestone) / Double(nextMilestone - previousMilestone)
        return min(max(progress, 0), 1)
    }
}

// MARK: - StandBy Medium View (Streak + Mini Grid)

struct StandByMediumView: View {
    let entry: LifeBlocksEntry
    let colorScheme = GridColorScheme.green

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 16) {
                // Left side - Streak
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.title)
                            .foregroundStyle(.orange)

                        Text("\(entry.currentStreak)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                    }

                    Text("day streak")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Today's level
                    HStack(spacing: 2) {
                        Text("Today:")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(scoreText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(colorScheme.color(for: entry.todayScore, isDarkMode: true))
                    }
                }
                .frame(maxWidth: .infinity)

                // Right side - Week Grid
                VStack(alignment: .leading, spacing: 8) {
                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // 7-day grid
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { daysAgo in
                            let date = Calendar.current.date(byAdding: .day, value: -(6 - daysAgo), to: Date())!
                            let score = entry.dayScores[Calendar.current.startOfDay(for: date)] ?? 0
                            let isToday = daysAgo == 6

                            VStack(spacing: 4) {
                                Text(dayLabel(for: daysAgo))
                                    .font(.system(size: 9))
                                    .foregroundStyle(.secondary)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(colorScheme.color(for: score, isDarkMode: true))
                                    .frame(width: 24, height: 24)
                                    .overlay {
                                        if isToday {
                                            RoundedRectangle(cornerRadius: 4)
                                                .strokeBorder(Color.white.opacity(0.5), lineWidth: 1.5)
                                        }
                                    }
                            }
                        }
                    }

                    // Legend
                    HStack(spacing: 4) {
                        Text("Less")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)

                        HStack(spacing: 2) {
                            ForEach(0..<5, id: \.self) { level in
                                RoundedRectangle(cornerRadius: 1)
                                    .fill(colorScheme.color(for: level, isDarkMode: true))
                                    .frame(width: 8, height: 8)
                            }
                        }

                        Text("More")
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .widgetURL(DeepLink.checkInURL())
    }

    private var scoreText: String {
        switch entry.todayScore {
        case 0: return "Not started"
        case 1: return "Light"
        case 2: return "Moderate"
        case 3: return "Good"
        case 4: return "Excellent"
        default: return "—"
        }
    }

    private func dayLabel(for daysAgo: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -(6 - daysAgo), to: Date())!
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Widget Bundle Update

// Note: Add this widget to your WidgetBundle:
// StandByWidget()

// MARK: - Previews

#Preview(as: .systemSmall) {
    StandByWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 23,
        todayScore: 3
    )
}

#Preview(as: .systemMedium) {
    StandByWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 15,
        todayScore: 2
    )
}
