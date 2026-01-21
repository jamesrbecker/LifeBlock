import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: LifeBlocksEntry

    private let colorScheme = GridColorScheme.green

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(entry.motivationalMessage)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                if entry.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Text(entry.streakEmoji)
                            .font(.caption2)
                        Text("\(entry.currentStreak)")
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundStyle(.orange)
                }
            }

            Link(destination: DeepLink.checkInURL()) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(colorScheme.color(for: entry.todayScore, isDarkMode: true))
                        .frame(width: 72, height: 72)

                    VStack(spacing: 2) {
                        if entry.checkedInToday {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                        Text(entry.checkedInToday ? "Done" : "Check in")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }

            HStack(spacing: 3) {
                ForEach(0..<7, id: \.self) { daysAgo in
                    let date = WidgetDateHelpers.daysAgo(6 - daysAgo)
                    let score = entry.dayScores[date.widgetStartOfDay] ?? 0

                    Link(destination: DeepLink.url(for: date)) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorScheme.color(for: score, isDarkMode: true))
                            .frame(width: 14, height: 14)
                            .overlay {
                                if date.widgetIsToday {
                                    RoundedRectangle(cornerRadius: 2)
                                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                                }
                            }
                    }
                }
            }

            Text("\(entry.weeklyCheckIns)/7 this week")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .padding(12)
    }
}

#Preview(as: .systemSmall) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 5,
        todayScore: 3
    )
}
