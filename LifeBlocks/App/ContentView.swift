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
    @State private var showingWeeklyReview = false
    @State private var showingLeaderboard = false

    private var todayEntry: DayEntry? {
        dayEntries.first { $0.date.isSameDay(as: Date()) }
    }

    private var hasCheckedInToday: Bool {
        todayEntry?.checkedIn ?? false
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Path dashboard (if user has selected a path)
                    if AppSettings.shared.userLifePath != nil {
                        PathDashboardView()
                            .padding(.horizontal)
                    }

                    // Quick action check-in card
                    QuickActionCard(hasCheckedInToday: hasCheckedInToday) {
                        showingCheckIn = true
                    }
                    .padding(.horizontal)

                    // Contribution grid
                    gridSection

                    // Quick stats
                    statsRow

                    // Future preview (motivational)
                    FuturePreviewCard(currentStreak: AppSettings.shared.currentStreak)
                        .padding(.horizontal)
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
                            showingWeeklyReview = true
                        } label: {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            HapticManager.shared.lightTap()
                            showingLeaderboard = true
                        } label: {
                            Image(systemName: "trophy")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingCheckIn) {
                DailyCheckInView()
                    .onDisappear {
                        // Sync widget data after check-in
                        DataManager.shared.configure(with: modelContext)
                        DataManager.shared.syncWidgetData()
                    }
            }
            .sheet(isPresented: $showingDayDetail) {
                if let date = selectedDate {
                    DayDetailView(date: date)
                }
            }
            .sheet(isPresented: $showingWeeklyReview) {
                WeeklyReviewView()
            }
            .sheet(isPresented: $showingLeaderboard) {
                LeaderboardView()
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
        }
    }

    private var todayCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(DateHelpers.formatDate(Date(), style: .medium))
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Text(hasCheckedInToday ? "Checked in!" : "Ready to check in?")
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                // Today's score square
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(GridColorScheme.green.color(for: todayEntry?.totalScore ?? 0, isDarkMode: true))
                        .frame(width: 60, height: 60)

                    if let score = todayEntry?.totalScore {
                        Text("\(score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }

            // Check-in button
            Button {
                showingCheckIn = true
            } label: {
                HStack {
                    Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(hasCheckedInToday ? "Update Check-in" : "Check In Now")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(hasCheckedInToday ? Color.cardBackground : Color.accentGreen)
                .foregroundColor(hasCheckedInToday ? .primary : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    if hasCheckedInToday {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.accentGreen, lineWidth: 2)
                    }
                }
            }

            // Streak badge
            if AppSettings.shared.currentStreak > 0 {
                HStack {
                    StreakBadge(streak: AppSettings.shared.currentStreak, size: .medium)
                    Spacer()
                    Text("\(habits.count) habits tracked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    private var gridSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Year")
                    .font(.headline)

                Spacer()

                NavigationLink {
                    StatsView()
                } label: {
                    Text("See Stats")
                        .font(.caption)
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

    private var statsRow: some View {
        HStack(spacing: 16) {
            QuickStatCard(
                title: "Streak",
                value: "\(AppSettings.shared.currentStreak)",
                icon: "flame.fill",
                color: .orange
            )

            QuickStatCard(
                title: "This Week",
                value: "\(weeklyCheckIns)",
                icon: "calendar",
                color: .blue
            )

            QuickStatCard(
                title: "Best",
                value: "\(AppSettings.shared.longestStreak)",
                icon: "trophy.fill",
                color: .yellow
            )
        }
        .padding(.horizontal)
    }

    private var weeklyCheckIns: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return dayEntries.filter { $0.date >= weekStart && $0.checkedIn }.count
    }

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
}

// Interactive grid that allows tapping on dates
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
                            .foregroundStyle(.secondary)
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
                            .foregroundStyle(.secondary)
                            .frame(width: 20, height: squareSize, alignment: .trailing)
                    }
                }

                // Grid with tap handlers
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
                .foregroundStyle(.secondary)
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
