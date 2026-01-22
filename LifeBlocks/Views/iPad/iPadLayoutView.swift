import SwiftUI
import SwiftData

// MARK: - iPad Optimized Layout
/// Uses NavigationSplitView for better iPad experience

struct iPadLayoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query private var dayEntries: [DayEntry]
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @State private var selectedSection: SidebarSection? = .grid
    @State private var selectedDate: Date?
    @State private var showingCheckIn = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    enum SidebarSection: String, CaseIterable, Identifiable {
        case grid = "Grid"
        case stats = "Stats"
        case friends = "Friends"
        case habits = "Habits"
        case settings = "Settings"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .grid: return "square.grid.3x3.fill"
            case .stats: return "chart.bar.fill"
            case .friends: return "person.2.fill"
            case .habits: return "list.bullet"
            case .settings: return "gearshape.fill"
            }
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            sidebar
        } content: {
            contentView
        } detail: {
            detailView
        }
        .sheet(isPresented: $showingCheckIn) {
            DailyCheckInView()
                .onDisappear {
                    DataManager.shared.configure(with: modelContext)
                    DataManager.shared.syncWidgetData()
                }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        List(selection: $selectedSection) {
            Section {
                ForEach(SidebarSection.allCases) { section in
                    NavigationLink(value: section) {
                        Label(section.rawValue, systemImage: section.icon)
                    }
                }
            }

            Section("Quick Stats") {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("Streak")
                    Spacer()
                    Text("\(AppSettings.shared.currentStreak) days")
                        .foregroundStyle(Color.secondaryText)
                }

                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Best")
                    Spacer()
                    Text("\(AppSettings.shared.longestStreak) days")
                        .foregroundStyle(Color.secondaryText)
                }

                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.blue)
                    Text("This Week")
                    Spacer()
                    Text("\(weeklyCheckIns) check-ins")
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Section {
                Button {
                    showingCheckIn = true
                } label: {
                    Label("Check In Now", systemImage: "plus.circle.fill")
                        .foregroundStyle(Color.accentGreen)
                }
            }
        }
        .navigationTitle("Blocks")
    }

    // MARK: - Content View (Middle Column)

    @ViewBuilder
    private var contentView: some View {
        switch selectedSection {
        case .grid, .none:
            GridContentView(
                dayEntries: dayEntries,
                onDateSelected: { date in
                    selectedDate = date
                }
            )
        case .stats:
            StatsContentView()
        case .friends:
            FriendsView()
        case .habits:
            HabitListView()
        case .settings:
            SettingsView()
        }
    }

    // MARK: - Detail View (Right Column)

    @ViewBuilder
    private var detailView: some View {
        if let date = selectedDate {
            DayDetailView(date: date)
        } else {
            ContentUnavailableView(
                "Select a Day",
                systemImage: "calendar",
                description: Text("Tap on a day in the grid to view details")
            )
        }
    }

    private var weeklyCheckIns: Int {
        let weekStart = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return dayEntries.filter { $0.date >= weekStart && $0.checkedIn }.count
    }
}

// MARK: - Grid Content View for iPad

struct GridContentView: View {
    let dayEntries: [DayEntry]
    let onDateSelected: (Date) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Path Dashboard
                if AppSettings.shared.userLifePath != nil {
                    PathDashboardView()
                        .padding(.horizontal)
                }

                // Full Year Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Year")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        LargeContributionGridView(
                            dayEntries: dayEntries,
                            onDateSelected: onDateSelected
                        )
                        .padding(.horizontal)
                    }
                }

                // Monthly Summary Cards
                MonthlyStatsGrid()
                    .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Activity Grid")
    }
}

// MARK: - Large Contribution Grid for iPad

struct LargeContributionGridView: View {
    let dayEntries: [DayEntry]
    let onDateSelected: (Date) -> Void
    let colorScheme: GridColorScheme = .green
    let weeks: Int = 52
    let squareSize: CGFloat = 16
    let spacing: CGFloat = 4

    private var gridDates: [[Date]] {
        DateHelpers.gridDates(weeks: weeks)
    }

    private var monthLabels: [(month: String, weekIndex: Int)] {
        DateHelpers.monthLabels(for: gridDates)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month labels
            GeometryReader { geometry in
                let weekWidth = squareSize + spacing
                let labelOffset: CGFloat = 30

                ZStack(alignment: .leading) {
                    ForEach(monthLabels, id: \.weekIndex) { label in
                        Text(label.month)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                            .offset(x: labelOffset + CGFloat(label.weekIndex) * weekWidth)
                    }
                }
            }
            .frame(height: 20)

            HStack(alignment: .top, spacing: spacing) {
                // Weekday labels
                VStack(spacing: spacing) {
                    ForEach(["", "Mon", "", "Wed", "", "Fri", ""], id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                            .frame(width: 26, height: squareSize, alignment: .trailing)
                    }
                }

                // Grid
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(Array(gridDates.enumerated()), id: \.offset) { weekIndex, week in
                        VStack(spacing: spacing) {
                            ForEach(week, id: \.self) { date in
                                Button {
                                    onDateSelected(date)
                                } label: {
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(colorScheme.color(for: levelForDate(date), isDarkMode: true))
                                        .frame(width: squareSize, height: squareSize)
                                        .overlay {
                                            if date.isSameDay(as: Date()) {
                                                RoundedRectangle(cornerRadius: 3)
                                                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 1.5)
                                            }
                                        }
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

// MARK: - Stats Content View for iPad

struct StatsContentView: View {
    var body: some View {
        StatsView()
    }
}

// MARK: - Monthly Stats Grid

struct MonthlyStatsGrid: View {
    let months = Calendar.current.shortMonthSymbols

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Overview")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(0..<12, id: \.self) { monthIndex in
                    MonthStatCard(monthIndex: monthIndex)
                }
            }
        }
    }
}

struct MonthStatCard: View {
    let monthIndex: Int
    @Query private var dayEntries: [DayEntry]

    private var monthName: String {
        Calendar.current.shortMonthSymbols[monthIndex]
    }

    private var checkInsThisMonth: Int {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        return dayEntries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date) - 1
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == monthIndex && entryYear == currentYear && entry.checkedIn
        }.count
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(monthName)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)

            Text("\(checkInsThisMonth)")
                .font(.title3)
                .fontWeight(.bold)

            Text("check-ins")
                .font(.caption2)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Adaptive Layout

struct AdaptiveRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        if horizontalSizeClass == .regular {
            iPadLayoutView()
        } else {
            MainTabView()
        }
    }
}

// MARK: - Preview

#Preview {
    iPadLayoutView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, DayEntry.self, UserSettings.self, Friend.self], inMemory: true)
        .preferredColorScheme(.dark)
}
