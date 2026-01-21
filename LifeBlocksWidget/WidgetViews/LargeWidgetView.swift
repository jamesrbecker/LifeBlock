import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: LifeBlocksEntry

    private var colorScheme: GridColorScheme {
        GridColorScheme.userSelected
    }

    private let squareSize: CGFloat = 12
    private let spacing: CGFloat = 3

    private var gridDates: [[Date]] {
        WidgetDateHelpers.gridDates(weeks: 20)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        WidgetDateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        Link(destination: DeepLink.checkInURL()) {
            VStack(alignment: .leading, spacing: 8) {
                // Month labels
                monthLabelsSection

                // Main grid
                gridSection

                Spacer(minLength: 4)

                // Minimal footer
                footerSection
            }
            .padding(14)
        }
        .containerBackground(Color(hex: "#0D1117"), for: .widget)
    }

    private var monthLabelsSection: some View {
        GeometryReader { geometry in
            let weekWidth = squareSize + spacing

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
        .padding(.leading, 18)
    }

    private var gridSection: some View {
        HStack(alignment: .top, spacing: spacing) {
            // Day labels
            VStack(spacing: spacing) {
                ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 14, height: squareSize)
                }
            }

            // Grid
            HStack(alignment: .top, spacing: spacing) {
                ForEach(Array(gridDates.enumerated()), id: \.offset) { _, week in
                    VStack(spacing: spacing) {
                        ForEach(week, id: \.self) { date in
                            let score = entry.dayScores[date.widgetStartOfDay] ?? 0

                            RoundedRectangle(cornerRadius: 2)
                                .fill(colorScheme.color(for: score, isDarkMode: true))
                                .frame(width: squareSize, height: squareSize)
                                .overlay {
                                    if date.widgetIsToday {
                                        RoundedRectangle(cornerRadius: 2)
                                            .strokeBorder(Color.white.opacity(0.6), lineWidth: 1)
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
    }

    private var footerSection: some View {
        HStack {
            // Streak info
            if entry.currentStreak > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                    Text("\(entry.currentStreak) day streak")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Legend
            HStack(spacing: 3) {
                Text("Less")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)

                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorScheme.color(for: level, isDarkMode: true))
                            .frame(width: 10, height: 10)
                    }
                }

                Text("More")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
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
