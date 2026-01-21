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
                VStack(spacing: 20) {
                    // Timeframe picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Streak cards - simplified
                    HStack(spacing: 12) {
                        SimpleStreakCard(
                            title: "Current",
                            value: currentStreak,
                            color: .orange
                        )

                        SimpleStreakCard(
                            title: "Best",
                            value: longestStreak,
                            color: .yellow
                        )
                    }
                    .padding(.horizontal)

                    // Key stats - simplified to just 2
                    HStack(spacing: 12) {
                        SimpleStatCard(
                            value: "\(filteredEntries.count)",
                            label: "check-ins"
                        )

                        SimpleStatCard(
                            value: String(format: "%.0f%%", completionRate),
                            label: "completion"
                        )
                    }
                    .padding(.horizontal)

                    // Score distribution
                    ScoreDistributionView(entries: filteredEntries)
                        .padding(.horizontal)

                    Spacer(minLength: 40)
                }
                .padding(.top)
            }
            .background(Color.gridBackground)
            .navigationTitle("Statistics")
        }
    }

}

// MARK: - Simplified Components

struct SimpleStreakCard: View {
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(color)

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

struct SimpleStatCard: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
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
                            .foregroundStyle(Color.secondaryText)

                        Text("L\(level)")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
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
