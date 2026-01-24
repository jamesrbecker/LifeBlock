import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: LifeBlocksEntry
    @Environment(\.colorScheme) private var systemColorScheme

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    private let squareSize: CGFloat = 14
    private let spacing: CGFloat = 3

    // Contribution grid: 80 days past + 10 future for large widget
    private var gridDates: [[Date]] {
        WidgetDateHelpers.contributionGridDates(pastDays: 80, futureDays: 10)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        WidgetDateHelpers.monthLabels(for: gridDates)
    }

    /// Border color for today - dark gray for contrast on light background
    private var todayBorderColor: Color {
        Color(hex: "#1B1F23")
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(alignment: .center, spacing: 8) {
                // Month labels
                monthLabelsSection

                // Main grid - centered
                gridSection

                Spacer(minLength: 4)

                // Minimal footer
                footerSection
            }
            .padding(14)
        }
        .containerBackground(GridColorScheme.widgetBackground(isDarkMode: isDarkMode), for: .widget)
    }

    private var monthLabelsSection: some View {
        GeometryReader { _ in
            let weekWidth = squareSize + spacing
            let labelOffset: CGFloat = 18 // Account for day labels

            ZStack(alignment: .leading) {
                ForEach(monthLabels, id: \.weekIndex) { label in
                    Text(label.month)
                        .font(.system(size: 9))
                        .foregroundStyle(Color(hex: "#57606A"))
                        .offset(x: labelOffset + CGFloat(label.weekIndex) * weekWidth)
                }
            }
        }
        .frame(height: 12)
    }

    private var gridSection: some View {
        HStack(alignment: .top, spacing: spacing) {
            // Day labels - dark text for light background
            VStack(spacing: spacing) {
                ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(Color(hex: "#57606A"))
                        .frame(width: 14, height: squareSize)
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
    }

    private var footerSection: some View {
        EmptyView()
    }
}

#Preview(as: .systemLarge) {
    LifeBlocksWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 23,
        todayScore: 4
    )
}
