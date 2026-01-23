import WidgetKit
import SwiftUI

// MARK: - Dedicated Streak Widget
/// A beautiful streak-focused widget with milestone tracking

struct StreakWidget: Widget {
    let kind: String = "LifeBlocksStreakWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeBlocksTimelineProvider()) { entry in
            StreakWidgetView(entry: entry)
                .containerBackground(Color(hex: "#0D1117"), for: .widget)
        }
        .configurationDisplayName("Streak Tracker")
        .description("Keep your streak alive with this motivational display.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Streak Widget Views

struct StreakWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: LifeBlocksEntry

    var body: some View {
        switch family {
        case .systemSmall:
            StreakSmallView(entry: entry)
        case .systemMedium:
            StreakMediumView(entry: entry)
        case .accessoryCircular:
            StreakCircularView(entry: entry)
        case .accessoryRectangular:
            StreakRectangularView(entry: entry)
        default:
            StreakSmallView(entry: entry)
        }
    }
}

// MARK: - Small Streak View

struct StreakSmallView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        VStack(spacing: 8) {
            // Streak emoji based on level
            Text(entry.streakEmoji)
                .font(.system(size: 40))

            // Streak number
            Text("\(entry.currentStreak)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(streakGradient)

            // Label
            Text("day streak")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Milestone progress
            if let (current, next) = nextMilestone {
                VStack(spacing: 4) {
                    ProgressView(value: milestoneProgress)
                        .progressViewStyle(.linear)
                        .tint(.orange)
                        .frame(height: 4)

                    Text("\(next - entry.currentStreak) to \(next)")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
            }
        }
        .widgetURL(DeepLink.checkInURL())
    }

    private var streakGradient: LinearGradient {
        if entry.currentStreak >= 100 {
            return LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
        } else if entry.currentStreak >= 30 {
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        } else if entry.currentStreak >= 7 {
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        }
    }

    private var nextMilestone: (current: Int, next: Int)? {
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365, 500, 1000]
        guard let next = milestones.first(where: { $0 > entry.currentStreak }) else { return nil }
        let current = milestones.last(where: { $0 <= entry.currentStreak }) ?? 0
        return (current, next)
    }

    private var milestoneProgress: Double {
        guard let (current, next) = nextMilestone else { return 1.0 }
        return Double(entry.currentStreak - current) / Double(next - current)
    }
}

// MARK: - Medium Streak View

struct StreakMediumView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        HStack(spacing: 20) {
            // Left - Big streak number
            VStack(spacing: 4) {
                Text(entry.streakEmoji)
                    .font(.system(size: 36))

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(entry.currentStreak)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(streakGradient)

                    Text("days")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }

                Text(entry.motivationalMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .frame(height: 80)

            // Right - Stats
            VStack(alignment: .leading, spacing: 12) {
                StatRow(icon: "trophy.fill", label: "Longest", value: "\(entry.longestStreak)", color: .yellow)
                StatRow(icon: "calendar", label: "This Week", value: "\(entry.weeklyCheckIns)/7", color: .blue)
                StatRow(icon: "target", label: "Next Goal", value: nextMilestoneText, color: .green)
            }
        }
        .padding()
        .widgetURL(DeepLink.checkInURL())
    }

    private var streakGradient: LinearGradient {
        if entry.currentStreak >= 100 {
            return LinearGradient(colors: [.purple, .pink], startPoint: .top, endPoint: .bottom)
        } else if entry.currentStreak >= 30 {
            return LinearGradient(colors: [.orange, .red], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
        }
    }

    private var nextMilestoneText: String {
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365, 500, 1000]
        guard let next = milestones.first(where: { $0 > entry.currentStreak }) else { return "🏆" }
        let daysLeft = next - entry.currentStreak
        return "\(daysLeft) to \(next)"
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 20)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Circular Lock Screen View

struct StreakCircularView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            // Progress ring
            Circle()
                .trim(from: 0, to: milestoneProgress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)

            VStack(spacing: 0) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 10))
                Text("\(entry.currentStreak)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
        }
    }

    private var milestoneProgress: Double {
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365]
        let next = milestones.first(where: { $0 > entry.currentStreak }) ?? 365
        let current = milestones.last(where: { $0 <= entry.currentStreak }) ?? 0
        return Double(entry.currentStreak - current) / Double(next - current)
    }
}

// MARK: - Rectangular Lock Screen View

struct StreakRectangularView: View {
    var entry: LifeBlocksEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                Text("\(entry.currentStreak) day streak")
                    .fontWeight(.bold)
            }

            HStack {
                Text(entry.motivationalMessage)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                // Mini progress bar
                ProgressView(value: milestoneProgress)
                    .progressViewStyle(.linear)
                    .frame(width: 40)
            }
        }
    }

    private var milestoneProgress: Double {
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365]
        let next = milestones.first(where: { $0 > entry.currentStreak }) ?? 365
        let current = milestones.last(where: { $0 <= entry.currentStreak }) ?? 0
        return Double(entry.currentStreak - current) / Double(next - current)
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    StreakWidget()
} timeline: {
    LifeBlocksEntry(date: Date(), dayScores: [:], currentStreak: 5, todayScore: 2)
    LifeBlocksEntry(date: Date(), dayScores: [:], currentStreak: 23, todayScore: 3)
    LifeBlocksEntry(date: Date(), dayScores: [:], currentStreak: 100, todayScore: 4)
}

#Preview(as: .systemMedium) {
    StreakWidget()
} timeline: {
    LifeBlocksEntry(date: Date(), dayScores: [:], currentStreak: 14, todayScore: 3, longestStreak: 28, weeklyCheckIns: 5)
}

#Preview(as: .accessoryCircular) {
    StreakWidget()
} timeline: {
    LifeBlocksEntry(date: Date(), dayScores: [:], currentStreak: 23, todayScore: 2)
}
