import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: LifeBlocksEntry

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    // 7x7 grid for small widget (last 7 weeks)
    private var gridDates: [[Date]] {
        WidgetDateHelpers.gridDates(weeks: 7)
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(spacing: 0) {
                // GitHub-style contribution grid
                HStack(alignment: .top, spacing: 2) {
                    ForEach(Array(gridDates.enumerated()), id: \.offset) { _, week in
                        VStack(spacing: 2) {
                            ForEach(week, id: \.self) { date in
                                let score = entry.dayScores[date.widgetStartOfDay] ?? 0
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorScheme.color(for: score, isDarkMode: true))
                                    .frame(width: 16, height: 16)
                                    .overlay {
                                        if date.widgetIsToday {
                                            RoundedRectangle(cornerRadius: 2)
                                                .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
                                        }
                                    }
                            }

                            // Pad incomplete weeks
                            if week.count < 7 {
                                ForEach(0..<(7 - week.count), id: \.self) { _ in
                                    Color.clear
                                        .frame(width: 16, height: 16)
                                }
                            }
                        }
                    }
                }

                Spacer(minLength: 4)

                // Minimal footer
                HStack {
                    Text("Blocks")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)

                    Spacer()

                    if entry.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                            Text("\(entry.currentStreak)")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.orange)
                    }
                }
            }
            .padding(12)
        }
        .containerBackground(Color(hex: "#0D1117"), for: .widget)
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
