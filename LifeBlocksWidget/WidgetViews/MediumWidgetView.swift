import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: LifeBlocksEntry

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    // 12 weeks for medium widget
    private var gridDates: [[Date]] {
        WidgetDateHelpers.gridDates(weeks: 12)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        WidgetDateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(alignment: .leading, spacing: 6) {
                // Month labels
                GeometryReader { geometry in
                    let weekWidth: CGFloat = 13
                    ZStack(alignment: .leading) {
                        ForEach(monthLabels, id: \.weekIndex) { label in
                            Text(label.month)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .offset(x: CGFloat(label.weekIndex) * weekWidth)
                        }
                    }
                }
                .frame(height: 12)
                .padding(.leading, 16)

                // GitHub-style contribution grid
                HStack(alignment: .top, spacing: 2) {
                    // Day labels
                    VStack(spacing: 2) {
                        ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                            Text(label)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                                .frame(width: 12, height: 11)
                        }
                    }

                    // Grid
                    HStack(alignment: .top, spacing: 2) {
                        ForEach(Array(gridDates.enumerated()), id: \.offset) { _, week in
                            VStack(spacing: 2) {
                                ForEach(week, id: \.self) { date in
                                    let score = entry.dayScores[date.widgetStartOfDay] ?? 0
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(colorScheme.color(for: score, isDarkMode: true))
                                        .frame(width: 11, height: 11)
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
                                            .frame(width: 11, height: 11)
                                    }
                                }
                            }
                        }
                    }
                }

                // Minimal footer with legend
                HStack {
                    if entry.currentStreak > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text("\(entry.currentStreak) day streak")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    // Legend
                    HStack(spacing: 2) {
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
            .padding(12)
        }
        .containerBackground(Color(hex: "#0D1117"), for: .widget)
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
