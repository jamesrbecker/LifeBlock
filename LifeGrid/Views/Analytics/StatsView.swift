import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]

    @State private var selectedTimeframe: Timeframe = .month

    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .year: return 365
            }
        }
    }

    private var filteredEntries: [DayEntry] {
        let startDate = DateHelpers.daysAgo(selectedTimeframe.days)
        return dayEntries.filter { $0.date >= startDate && $0.checkedIn }
    }

    private var currentStreak: Int {
        AppSettings.shared.currentStreak
    }

    private var longestStreak: Int {
        AppSettings.shared.longestStreak
    }

    private var averageScore: Double {
        guard !filteredEntries.isEmpty else { return 0 }
        return Double(filteredEntries.reduce(0) { $0 + $1.totalScore }) / Double(filteredEntries.count)
    }

    private var completionRate: Double {
        guard selectedTimeframe.days > 0 else { return 0 }
        return Double(filteredEntries.count) / Double(selectedTimeframe.days) * 100
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Streak cards
                    HStack(spacing: 16) {
                        StreakCard(
                            title: "Current Streak",
                            value: currentStreak,
                            icon: "flame.fill",
                            color: .orange
                        )

                        StreakCard(
                            title: "Best Streak",
                            value: longestStreak,
                            icon: "trophy.fill",
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)

                    // Stats grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatBox(
                            title: "Check-ins",
                            value: "\(filteredEntries.count)",
                            subtitle: "in \(selectedTimeframe.rawValue.lowercased())",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )

                        StatBox(
                            title: "Avg Score",
                            value: String(format: "%.1f", averageScore),
                            subtitle: "out of 4",
                            icon: "chart.bar.fill",
                            color: .blue
                        )

                        StatBox(
                            title: "Completion",
                            value: String(format: "%.0f%%", completionRate),
                            subtitle: "days tracked",
                            icon: "percent",
                            color: .purple
                        )

                        StatBox(
                            title: "Total Days",
                            value: "\(dayEntries.filter { $0.checkedIn }.count)",
                            subtitle: "all time",
                            icon: "calendar",
                            color: .pink
                        )
                    }
                    .padding(.horizontal)

                    // Score distribution
                    ScoreDistributionView(entries: filteredEntries)
                        .padding(.horizontal)

                    // Motivational message (positive only!)
                    motivationalCard
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.gridBackground)
            .navigationTitle("Statistics")
        }
    }

    private var motivationalCard: some View {
        VStack(spacing: 12) {
            Image(systemName: motivationalIcon)
                .font(.largeTitle)
                .foregroundStyle(Color.accentGreen)

            Text(motivationalMessage)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(motivationalSubtext)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var motivationalIcon: String {
        if currentStreak >= 30 { return "star.fill" }
        if currentStreak >= 7 { return "flame.fill" }
        if filteredEntries.count > 0 { return "hand.thumbsup.fill" }
        return "sparkles"
    }

    private var motivationalMessage: String {
        if currentStreak >= 30 {
            return "You're building something amazing!"
        }
        if currentStreak >= 7 {
            return "A week of consistency!"
        }
        if currentStreak >= 1 {
            return "Keep the momentum going!"
        }
        if !filteredEntries.isEmpty {
            return "Every check-in counts!"
        }
        return "Ready to start your journey?"
    }

    private var motivationalSubtext: String {
        if currentStreak >= 30 {
            return "A month of dedication shows real commitment. You're proving what's possible."
        }
        if currentStreak >= 7 {
            return "You've built a solid foundation. Each day makes the next one easier."
        }
        if currentStreak >= 1 {
            return "You showed up today, and that's what matters. Small steps lead to big changes."
        }
        if !filteredEntries.isEmpty {
            return "You've already made progress. Pick up where you left off - it's never too late."
        }
        return "Start tracking today and watch your progress grow over time."
    }
}

struct StreakCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("\(value)")
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text(value == 1 ? "day" : "days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct ScoreDistributionView: View {
    let entries: [DayEntry]

    private var distribution: [Int: Int] {
        var dist = [0: 0, 1: 0, 2: 0, 3: 0, 4: 0]
        for entry in entries {
            dist[entry.totalScore, default: 0] += 1
        }
        return dist
    }

    private var maxCount: Int {
        distribution.values.max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Score Distribution")
                .font(.headline)

            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<5, id: \.self) { level in
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(GridColorScheme.green.color(for: level, isDarkMode: true))
                            .frame(width: 40, height: barHeight(for: level))

                        // Label
                        Text("\(distribution[level] ?? 0)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("L\(level)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120, alignment: .bottom)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func barHeight(for level: Int) -> CGFloat {
        guard maxCount > 0 else { return 10 }
        let count = distribution[level] ?? 0
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return max(10, ratio * 80)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: [DayEntry.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
