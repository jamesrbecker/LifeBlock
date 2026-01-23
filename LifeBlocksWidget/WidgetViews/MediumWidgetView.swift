import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: LifeBlocksEntry
    @Environment(\.colorScheme) private var systemColorScheme

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    // GitHub-style: 80 days past + 10 future
    private var gridDates: [[Date]] {
        WidgetDateHelpers.githubStyleGridDates(pastDays: 80, futureDays: 10)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        WidgetDateHelpers.monthLabels(for: gridDates)
    }

    private let squareSize: CGFloat = 12
    private let spacing: CGFloat = 2.5

    private var todayBorderColor: Color {
        isDarkMode ? .white : Color(hex: "#1B1F23")
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(alignment: .center, spacing: 6) {
                // Month labels - centered above grid
                monthLabelsSection

                // GitHub-style contribution grid - centered
                HStack(alignment: .top, spacing: spacing) {
                    // Day labels
                    VStack(spacing: spacing) {
                        ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                            Text(label)
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                                .frame(width: 12, height: squareSize)
                        }
                    }

                    // Grid
                    HStack(alignment: .top, spacing: spacing) {
                        ForEach(Array(gridDates.enumerated()), id: \.offset) { weekIndex, week in
                            let isCurrentWeekColumn = week.contains(where: { $0.widgetIsToday })

                            VStack(spacing: spacing) {
                                ForEach(week, id: \.self) { date in
                                    let isFuture = WidgetDateHelpers.isFuture(date)
                                    let score = isFuture ? 0 : (entry.dayScores[date.widgetStartOfDay] ?? 0)
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(isFuture ? GridColorScheme.futureColor(isDarkMode: isDarkMode) : colorScheme.color(for: score, isDarkMode: isDarkMode))
                                        .frame(width: squareSize, height: squareSize)
                                        .overlay {
                                            if date.widgetIsToday {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .strokeBorder(todayBorderColor, lineWidth: 1.5)
                                            }
                                        }
                                }

                                // Pad incomplete weeks
                                if week.count < 7 {
                                    ForEach(0..<(7 - week.count), id: \.self) { _ in
                                        Color.clear
                                            .frame(width: squareSize, height: squareSize)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Minimal footer - streak only
                if entry.currentStreak > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(.orange)
                        Text("\(entry.currentStreak) day streak")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }
            }
            .padding(12)
        }
        .containerBackground(GridColorScheme.widgetBackground(isDarkMode: isDarkMode), for: .widget)
    }

    private var monthLabelsSection: some View {
        GeometryReader { _ in
            let weekWidth = squareSize + spacing
            let labelOffset: CGFloat = 14 // Account for day labels

            ZStack(alignment: .leading) {
                ForEach(monthLabels, id: \.weekIndex) { label in
                    Text(label.month)
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                        .offset(x: labelOffset + CGFloat(label.weekIndex) * weekWidth)
                }
            }
        }
        .frame(height: 12)
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
