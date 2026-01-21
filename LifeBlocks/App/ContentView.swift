import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @State private var showingCheckIn = false
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false
    @State private var showingMilestoneCelebration = false
    @State private var milestoneToShow: Int = 0
    @State private var showingShareGrid = false
    @State private var showingLeaderboard = false

    private var todayEntry: DayEntry? {
        dayEntries.first { $0.date.isSameDay(as: Date()) }
    }

    private var hasCheckedInToday: Bool {
        todayEntry?.checkedIn ?? false
    }

    private var weeklyCheckIns: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return dayEntries.filter { $0.date >= weekStart && $0.checkedIn }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Main check-in button
                    checkInButton

                    // Contribution grid
                    gridSection

                    // Compact stats (streak + weekly)
                    compactStats
                }
                .padding(.vertical)
            }
            .background(Color.gridBackground)
            .navigationTitle("LifeBlocks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    HStack(spacing: 16) {
                        Button {
                            HapticManager.shared.lightTap()
                            showingLeaderboard = true
                        } label: {
                            Image(systemName: "trophy")
                                .foregroundStyle(Color.secondaryText)
                        }

                        Button {
                            HapticManager.shared.lightTap()
                            showingShareGrid = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingCheckIn) {
                DailyCheckInView()
                    .onDisappear {
                        DataManager.shared.configure(with: modelContext)
                        DataManager.shared.syncWidgetData()
                        checkForMilestone()
                    }
            }
            .fullScreenCover(isPresented: $showingMilestoneCelebration) {
                StreakMilestoneCelebrationView(milestone: milestoneToShow) {
                    showingMilestoneCelebration = false
                    AppSettings.shared.celebrateMilestone(milestoneToShow)
                }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailView(date: date)
                }
            }
            .sheet(isPresented: $showingShareGrid) {
                ShareGridView(
                    dayEntries: dayEntries,
                    currentStreak: AppSettings.shared.currentStreak,
                    longestStreak: AppSettings.shared.longestStreak
                )
            }
            .sheet(isPresented: $showingLeaderboard) {
                LeaderboardView()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    // MARK: - Check-In Button

    private var checkInButton: some View {
        Button {
            HapticManager.shared.mediumTap()
            showingCheckIn = true
        } label: {
            HStack(spacing: 16) {
                // Today's score indicator
                ZStack {
                    Circle()
                        .fill(hasCheckedInToday ? Color.accentGreen : Color.cardBackgroundLight)
                        .frame(width: 52, height: 52)

                    if hasCheckedInToday {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Image(systemName: "plus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.accentGreen)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(hasCheckedInToday ? "Checked in" : "Check in")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(DateHelpers.formatDate(Date(), style: .medium))
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if let score = todayEntry?.totalScore, score > 0 {
                    Text("\(score)")
                        .font(.title.weight(.bold))
                        .foregroundStyle(Color.accentGreen)
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    // MARK: - Grid Section

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Year")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    StatsView()
                } label: {
                    Text("Stats")
                        .font(.subheadline)
                        .foregroundColor(Color.accentGreen)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                InteractiveContributionGridView(
                    onDateSelected: { date in
                        selectedDate = date
                        showingDayDetail = true
                    }
                )
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Compact Stats

    private var compactStats: some View {
        HStack(spacing: 12) {
            // Streak
            HStack(spacing: 8) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(AppSettings.shared.currentStreak)")
                        .font(.title3.weight(.bold))
                    Text("streak")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // This week
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(weeklyCheckIns)/7")
                        .font(.title3.weight(.bold))
                    Text("this week")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Best streak
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(AppSettings.shared.longestStreak)")
                        .font(.title3.weight(.bold))
                    Text("best")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "lifeblock" else { return }

        switch url.host {
        case "checkin":
            showingCheckIn = true

        case "day":
            if let timestampString = url.pathComponents.last,
               let timestamp = TimeInterval(timestampString) {
                selectedDate = Date(timeIntervalSince1970: timestamp)
                showingDayDetail = true
            }

        default:
            break
        }
    }

    private func checkForMilestone() {
        let currentStreak = AppSettings.shared.currentStreak
        let milestones = [7, 14, 21, 30, 50, 100, 150, 200, 365, 500, 1000]

        for milestone in milestones.reversed() {
            if currentStreak >= milestone && AppSettings.shared.lastCelebratedMilestone < milestone {
                milestoneToShow = milestone
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showingMilestoneCelebration = true
                }
                break
            }
        }
    }
}

// MARK: - Interactive Contribution Grid

struct InteractiveContributionGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]

    let onDateSelected: (Date) -> Void
    let colorScheme: GridColorScheme = .green
    let weeks: Int = 52
    let squareSize: CGFloat = 11
    let spacing: CGFloat = 3

    private var gridDates: [[Date]] {
        DateHelpers.gridDates(weeks: weeks)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        DateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month labels
            GeometryReader { geometry in
                let weekWidth = squareSize + spacing
                let labelOffset: CGFloat = 24

                ZStack(alignment: .leading) {
                    ForEach(monthLabels, id: \.weekIndex) { label in
                        Text(label.month)
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                            .offset(x: labelOffset + CGFloat(label.weekIndex) * weekWidth)
                    }
                }
            }
            .frame(height: 16)

            HStack(alignment: .top, spacing: spacing) {
                // Weekday labels
                VStack(spacing: spacing) {
                    ForEach(DateHelpers.weekdayLabels(), id: \.self) { label in
                        Text(label)
                            .font(.system(size: 9))
                            .foregroundStyle(Color.secondaryText)
                            .frame(width: 20, height: squareSize, alignment: .trailing)
                    }
                }

                // Grid
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(Array(gridDates.enumerated()), id: \.offset) { weekIndex, week in
                        VStack(spacing: spacing) {
                            ForEach(week, id: \.self) { date in
                                Button {
                                    HapticManager.shared.lightTap()
                                    onDateSelected(date)
                                } label: {
                                    DaySquareView(
                                        date: date,
                                        level: levelForDate(date),
                                        colorScheme: colorScheme,
                                        size: squareSize
                                    )
                                }
                                .buttonStyle(.plain)
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

            GridLegendView(colorScheme: colorScheme)
                .padding(.top, 8)
        }
    }

    private func levelForDate(_ date: Date) -> Int {
        let targetDate = date.startOfDay
        return dayEntries.first { $0.date.isSameDay(as: targetDate) }?.totalScore ?? 0
    }
}

// MARK: - Quick Stat Card (kept for other views)

struct QuickStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, DayEntry.self, UserSettings.self], inMemory: true)
        .preferredColorScheme(.dark)
}
