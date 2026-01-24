import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: LifeBlocksEntry
    @Environment(\.colorScheme) private var systemColorScheme

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    // Contribution grid: past days + future for widget
    private var gridDates: [[Date]] {
        WidgetDateHelpers.contributionGridDates(pastDays: 63, futureDays: 7)  // ~10 weeks for small widget
    }

    private let squareSize: CGFloat = 9
    private let spacing: CGFloat = 2

    /// Border color for today - dark gray for contrast on light background
    private var todayBorderColor: Color {
        Color(hex: "#1B1F23")
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(spacing: 0) {
                // Contribution grid - centered
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(Array(gridDates.enumerated()), id: \.offset) { _, week in
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
                                                .strokeBorder(todayBorderColor, lineWidth: 1)
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
                .frame(maxWidth: .infinity)

            }
            .padding(12)
        }
        .containerBackground(GridColorScheme.widgetBackground(isDarkMode: isDarkMode), for: .widget)
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
