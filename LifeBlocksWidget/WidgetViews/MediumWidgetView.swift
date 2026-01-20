import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: LifeBlocksEntry

    private let colorScheme = GridColorScheme.green

    private var last14Days: [Date] {
        (0..<14).map { WidgetDateHelpers.daysAgo(13 - $0) }
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 8) {
                if entry.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                        Text("\(entry.currentStreak) day streak")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.orange)
                }

                Link(destination: DeepLink.checkInURL()) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(colorScheme.color(for: entry.todayScore, isDarkMode: true))
                            .frame(width: 72, height: 72)

                        VStack(spacing: 2) {
                            Text("\(entry.todayScore)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))

                            Text("Today")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .foregroundStyle(.white)
                    }
                }

                Text(scoreLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 90)

            VStack(alignment: .leading, spacing: 8) {
                Text("Last 2 Weeks")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(0..<7, id: \.self) { index in
                            let date = last14Days[index]
                            daySquare(for: date)
                        }
                    }

                    HStack(spacing: 4) {
                        ForEach(7..<14, id: \.self) { index in
                            let date = last14Days[index]
                            daySquare(for: date)
                        }
                    }
                }

                HStack(spacing: 4) {
                    ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { label in
                        Text(label)
                            .font(.system(size: 8))
                            .foregroundStyle(.secondary)
                            .frame(width: 18)
                    }
                }
            }
        }
        .padding(16)
    }

    @ViewBuilder
    private func daySquare(for date: Date) -> some View {
        let score = entry.dayScores[date.widgetStartOfDay] ?? 0

        Link(destination: DeepLink.url(for: date)) {
            RoundedRectangle(cornerRadius: 3)
                .fill(colorScheme.color(for: score, isDarkMode: true))
                .frame(width: 18, height: 18)
                .overlay {
                    if date.widgetIsToday {
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                    }
                }
        }
    }

    private var scoreLabel: String {
        switch entry.todayScore {
        case 4: return "Maximum!"
        case 3: return "High"
        case 2: return "Moderate"
        case 1: return "Light"
        default: return "Check in"
        }
    }
}

#Preview(as: .systemMedium) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 12,
        todayScore: 3
    )
}
