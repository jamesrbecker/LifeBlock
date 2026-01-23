import SwiftUI
import SwiftData

struct ContributionGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]

    @State private var selectedDate: Date?
    @State private var gridScale: CGFloat = 1.0

    let colorScheme: GridColorScheme
    let pastDays: Int
    let futureDays: Int
    let squareSize: CGFloat
    let spacing: CGFloat

    init(
        colorScheme: GridColorScheme = ThemeManager.shared.currentTheme,
        pastDays: Int = 80,  // 80 days of history
        futureDays: Int = 10, // 10 days into the future
        squareSize: CGFloat = 14,  // Larger squares for better visibility
        spacing: CGFloat = 3
    ) {
        self.colorScheme = colorScheme
        self.pastDays = pastDays
        self.futureDays = futureDays
        self.squareSize = squareSize
        self.spacing = spacing
    }

    private var gridDates: [[Date]] {
        DateHelpers.contributionGridDates(pastDays: pastDays, futureDays: futureDays)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        DateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Month labels - centered
            monthLabelsView

            HStack(alignment: .top, spacing: spacing) {
                // Weekday labels
                weekdayLabelsView

                // Main grid
                gridView
            }

            // Legend
            GridLegendView(colorScheme: colorScheme)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(gridScale)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    gridScale = min(max(value, 0.5), 2.0)
                }
                .onEnded { _ in
                    withAnimation(.spring()) {
                        gridScale = 1.0
                    }
                }
        )
    }

    private var monthLabelsView: some View {
        GeometryReader { geometry in
            let weekWidth = squareSize + spacing
            let labelOffset: CGFloat = 24 // Account for weekday labels
            let minWeeksBetweenLabels = 4 // Minimum weeks between labels to prevent overlap

            // Filter out labels that would overlap
            let filteredLabels = monthLabels.enumerated().filter { index, label in
                if index == 0 { return true }
                let previousLabel = monthLabels[index - 1]
                return label.weekIndex - previousLabel.weekIndex >= minWeeksBetweenLabels
            }.map { $0.element }

            ZStack(alignment: .leading) {
                ForEach(filteredLabels, id: \.weekIndex) { label in
                    Text(label.month)
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                        .offset(x: labelOffset + CGFloat(label.weekIndex) * weekWidth)
                }
            }
        }
        .frame(height: 16)
    }

    private var weekdayLabelsView: some View {
        VStack(spacing: spacing) {
            ForEach(DateHelpers.weekdayLabels(), id: \.self) { label in
                Text(label)
                    .font(.system(size: 9))
                    .foregroundStyle(Color.secondaryText)
                    .frame(width: 20, height: squareSize, alignment: .trailing)
            }
        }
    }

    private var gridView: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(Array(gridDates.enumerated()), id: \.offset) { weekIndex, week in
                let isCurrentWeekColumn = weekIndex == gridDates.count - 1 ||
                    week.contains(where: { $0.isToday })

                VStack(spacing: spacing) {
                    ForEach(week, id: \.self) { date in
                        let isFutureDate = DateHelpers.isFuture(date)
                        DaySquareView(
                            date: date,
                            level: isFutureDate ? 0 : levelForDate(date),
                            colorScheme: colorScheme,
                            size: squareSize,
                            isSelected: selectedDate?.isSameDay(as: date) ?? false,
                            isFuture: isFutureDate,
                            isCurrentWeek: DateHelpers.isCurrentWeek(date)
                        )
                        .onTapGesture {
                            // Only allow tapping past/today dates
                            guard !isFutureDate else { return }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                if selectedDate?.isSameDay(as: date) ?? false {
                                    selectedDate = nil
                                } else {
                                    selectedDate = date
                                }
                            }
                        }
                    }

                    // Pad incomplete weeks at the start
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

    private func levelForDate(_ date: Date) -> Int {
        let targetDate = date.startOfDay
        return dayEntries.first { $0.date.isSameDay(as: targetDate) }?.totalScore ?? 0
    }
}

// Compact grid for widgets
struct CompactGridView: View {
    let entries: [Date: Int] // date -> level mapping
    let colorScheme: GridColorScheme
    let days: Int
    let squareSize: CGFloat
    let spacing: CGFloat

    init(
        entries: [Date: Int],
        colorScheme: GridColorScheme = ThemeManager.shared.currentTheme,
        days: Int = 7,
        squareSize: CGFloat = 14,
        spacing: CGFloat = 3
    ) {
        self.entries = entries
        self.colorScheme = colorScheme
        self.days = days
        self.squareSize = squareSize
        self.spacing = spacing
    }

    private var dates: [Date] {
        (0..<days).map { DateHelpers.daysAgo($0) }.reversed()
    }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(dates, id: \.self) { date in
                DaySquareView(
                    date: date,
                    level: entries[date.startOfDay] ?? 0,
                    colorScheme: colorScheme,
                    size: squareSize
                )
            }
        }
    }
}

// Preview
#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        ContributionGridView()
            .padding()
    }
    .background(Color.gridBackground)
    .preferredColorScheme(.dark)
}
