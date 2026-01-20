import SwiftUI
import SwiftData

// MARK: - Progress Report View (Premium)
/// Weekly and monthly progress reports with detailed analytics

struct ProgressReportView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]
    @Query private var habits: [Habit]

    @State private var selectedPeriod: ReportPeriod = .week
    @State private var showingShareSheet = false
    @State private var reportImage: UIImage?

    enum ReportPeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case quarter = "Last 90 Days"
        case year = "This Year"

        var days: Int {
            switch self {
            case .week: return 7
            case .month: return 30
            case .quarter: return 90
            case .year: return 365
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(ReportPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Summary Card
                SummaryCard(stats: calculateStats())

                // Activity Chart
                ActivityChartCard(entries: entriesForPeriod())

                // Habit Breakdown
                HabitBreakdownCard(habits: habits, entries: entriesForPeriod())

                // Streak Info
                StreakInfoCard()

                // Best Day
                BestDayCard(entries: entriesForPeriod())

                // Share Button
                Button {
                    generateAndShareReport()
                } label: {
                    Label("Share Report", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Progress Report")
        .sheet(isPresented: $showingShareSheet) {
            if let image = reportImage {
                ShareSheet(items: [image])
            }
        }
    }

    private func entriesForPeriod() -> [DayEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -selectedPeriod.days, to: Date()) ?? Date()
        return dayEntries.filter { $0.date >= startDate }
    }

    private func calculateStats() -> ReportStats {
        let entries = entriesForPeriod()
        let checkedInDays = entries.filter { $0.checkedIn }.count
        let totalScore = entries.reduce(0) { $0 + $1.totalScore }
        let avgScore = entries.isEmpty ? 0 : Double(totalScore) / Double(entries.count)

        return ReportStats(
            totalDays: selectedPeriod.days,
            checkedInDays: checkedInDays,
            averageScore: avgScore,
            totalScore: totalScore,
            completionRate: entries.isEmpty ? 0 : Double(checkedInDays) / Double(selectedPeriod.days) * 100
        )
    }

    private func generateAndShareReport() {
        // Generate report image for sharing
        showingShareSheet = true
    }
}

struct ReportStats {
    let totalDays: Int
    let checkedInDays: Int
    let averageScore: Double
    let totalScore: Int
    let completionRate: Double
}

// MARK: - Summary Card

struct SummaryCard: View {
    let stats: ReportStats

    var body: some View {
        VStack(spacing: 16) {
            Text("Summary")
                .font(.headline)

            HStack(spacing: 20) {
                StatBox(
                    value: "\(stats.checkedInDays)/\(stats.totalDays)",
                    label: "Days Active",
                    icon: "calendar"
                )

                StatBox(
                    value: String(format: "%.1f", stats.averageScore),
                    label: "Avg Score",
                    icon: "chart.bar.fill"
                )

                StatBox(
                    value: "\(Int(stats.completionRate))%",
                    label: "Completion",
                    icon: "checkmark.circle.fill"
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct StatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Chart Card

struct ActivityChartCard: View {
    let entries: [DayEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Over Time")
                .font(.headline)

            // Simple bar chart
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(entries.suffix(14), id: \.id) { entry in
                    VStack {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(colorForScore(entry.totalScore))
                            .frame(width: 16, height: CGFloat(entry.totalScore) * 15 + 5)
                    }
                }

                if entries.count < 14 {
                    ForEach(0..<(14 - entries.count), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 16, height: 5)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)

            HStack {
                Text("2 weeks ago")
                Spacer()
                Text("Today")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func colorForScore(_ score: Int) -> Color {
        switch score {
        case 0: return Color.gray.opacity(0.3)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green
        default: return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Habit Breakdown Card

struct HabitBreakdownCard: View {
    let habits: [Habit]
    let entries: [DayEntry]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Habit Performance")
                .font(.headline)

            ForEach(habits.filter { $0.isActive }.prefix(5)) { habit in
                HStack {
                    Image(systemName: habit.icon)
                        .foregroundStyle(.green)
                        .frame(width: 24)

                    Text(habit.name)
                        .lineLimit(1)

                    Spacer()

                    // Completion rate bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green)
                                .frame(width: geo.size.width * habit.completionRate / 100)
                        }
                    }
                    .frame(width: 80, height: 8)

                    Text("\(Int(habit.completionRate))%")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Streak Info Card

struct StreakInfoCard: View {
    var body: some View {
        let settings = AppSettings.shared

        VStack(spacing: 12) {
            HStack {
                VStack {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("\(settings.currentStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("\(settings.longestStreak)")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Text("Longest Streak")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Best Day Card

struct BestDayCard: View {
    let entries: [DayEntry]

    var bestDay: DayEntry? {
        entries.max(by: { $0.totalScore < $1.totalScore })
    }

    var body: some View {
        if let best = bestDay, best.totalScore > 0 {
            VStack(spacing: 8) {
                Text("Best Day")
                    .font(.headline)

                HStack {
                    VStack(alignment: .leading) {
                        Text(best.date, style: .date)
                            .font(.subheadline)
                        Text("Score: \(best.totalScore)/4")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "star.fill")
                        .font(.title)
                        .foregroundStyle(.yellow)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgressReportView()
    }
    .modelContainer(for: [DayEntry.self, Habit.self], inMemory: true)
    .preferredColorScheme(.dark)
}
