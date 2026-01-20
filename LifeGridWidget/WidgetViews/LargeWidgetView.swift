import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: LifeGridEntry

    private let colorScheme = GridColorScheme.green
    private let squareSize: CGFloat = 14
    private let spacing: CGFloat = 3

    private var gridDates: [[Date]] {
        WidgetDateHelpers.gridDates(weeks: 16)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        WidgetDateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerSection
            monthLabelsSection
            gridSection
            legendSection
        }
        .padding(16)
    }

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("LifeGrid")
                    .font(.headline)
                    .fontWeight(.bold)

                Text("Last 16 weeks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 16) {
                VStack(spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(entry.currentStreak)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    Text("Streak")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Link(destination: DeepLink.checkInURL()) {
                    VStack(spacing: 2) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(colorScheme.color(for: entry.todayScore, isDarkMode: true))
                                .frame(width: 28, height: 28)

                            Text("\(entry.todayScore)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                        }
                        Text("Today")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
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
            VStack(spacing: spacing) {
                ForEach(["", "M", "", "W", "", "F", ""], id: \.self) { label in
                    Text(label)
                        .font(.system(size: 8))
                        .foregroundStyle(.secondary)
                        .frame(width: 14, height: squareSize)
                }
            }

            HStack(alignment: .top, spacing: spacing) {
                ForEach(Array(gridDates.enumerated()), id: \.offset) { weekIndex, week in
                    VStack(spacing: spacing) {
                        ForEach(week, id: \.self) { date in
                            let score = entry.dayScores[date.widgetStartOfDay] ?? 0

                            Link(destination: DeepLink.url(for: date)) {
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

    private var legendSection: some View {
        HStack {
            Spacer()

            Text("Less")
                .font(.system(size: 9))
                .foregroundStyle(.secondary)

            HStack(spacing: 3) {
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

#Preview(as: .systemLarge) {
    LifeGridWidget()
} timeline: {
    LifeGridEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 23,
        todayScore: 4
    )
}
