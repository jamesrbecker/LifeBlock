import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: LifeGridEntry

    private let colorScheme = GridColorScheme.green

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Today")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                if entry.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
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
                        .frame(width: 80, height: 80)

                    VStack(spacing: 4) {
                        Text("\(entry.todayScore)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))

                        Text("Level")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .foregroundStyle(.white)
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
        }
        .padding(16)
    }
}

#Preview(as: .systemSmall) {
    LifeGridWidget()
} timeline: {
    LifeGridEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 5,
        todayScore: 3
    )
}
