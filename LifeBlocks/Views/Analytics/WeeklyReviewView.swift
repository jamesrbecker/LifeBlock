import SwiftUI
import SwiftData

struct WeeklyReviewView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var dayEntries: [DayEntry]
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    private var weekDates: [Date] {
        (0..<7).map { DateHelpers.daysAgo($0) }.reversed()
    }

    private var weekEntries: [DayEntry] {
        dayEntries.filter { entry in
            weekDates.contains { $0.isSameDay(as: entry.date) }
        }
    }

    private var checkedInDays: Int {
        weekEntries.filter { $0.checkedIn }.count
    }

    private var totalScore: Int {
        weekEntries.reduce(0) { $0 + $1.totalScore }
    }

    private var averageScore: Double {
        guard checkedInDays > 0 else { return 0 }
        return Double(totalScore) / Double(checkedInDays)
    }

    private var perfectDays: Int {
        weekEntries.filter { $0.totalScore == 4 }.count
    }

    private var bestDay: (day: String, score: Int)? {
        guard let best = weekEntries.max(by: { $0.totalScore < $1.totalScore }),
              best.totalScore > 0 else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return (formatter.string(from: best.date), best.totalScore)
    }

    private var streakStatus: String {
        let streak = AppSettings.shared.currentStreak
        if streak >= 7 {
            return "You're on fire! \(streak) day streak"
        } else if streak > 0 {
            return "\(streak) day streak - keep it going!"
        } else {
            return "Start a new streak today"
        }
    }

    private var weekSummary: String {
        if checkedInDays == 7 && perfectDays >= 3 {
            return "Incredible week! You showed up every day."
        } else if checkedInDays >= 5 {
            return "Strong week! Consistency is key."
        } else if checkedInDays >= 3 {
            return "Good effort! Room to grow next week."
        } else {
            return "Every week is a fresh start."
        }
    }

    private var motivationalQuote: String {
        let quotes = [
            "Small daily improvements lead to staggering long-term results.",
            "The secret of getting ahead is getting started.",
            "Success is the sum of small efforts repeated day in and day out.",
            "You don't have to be great to start, but you have to start to be great.",
            "Progress, not perfection.",
            "One day or day one. You decide."
        ]
        return quotes.randomElement() ?? quotes[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Week at a glance
                    weekGridSection

                    // Stats cards
                    statsSection

                    // Best day highlight
                    if let best = bestDay {
                        bestDaySection(day: best.day, score: best.score)
                    }

                    // Motivation
                    motivationSection

                    // Action button
                    actionButton
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Weekly Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HapticManager.shared.lightTap()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
            .onAppear {
                HapticManager.shared.mediumTap()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("This Week")
                .font(.caption)
                .foregroundStyle(Color.secondaryText)

            Text(weekSummary)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(streakStatus)
                .font(.subheadline)
                .foregroundStyle(AppSettings.shared.currentStreak > 0 ? .orange : Color.secondaryText)
        }
        .padding(.vertical)
    }

    // MARK: - Week Grid

    private var weekGridSection: some View {
        HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                let entry = weekEntries.first { $0.date.isSameDay(as: date) }
                let score = entry?.totalScore ?? 0

                VStack(spacing: 6) {
                    Text(dayAbbreviation(for: date))
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(GridColorScheme.green.color(for: score, isDarkMode: true))
                        .frame(width: 36, height: 36)
                        .overlay {
                            if score > 0 {
                                Text("\(score)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                            }
                        }

                    if date.isSameDay(as: Date()) {
                        Circle()
                            .fill(Color.accentGreen)
                            .frame(width: 4, height: 4)
                    } else {
                        Color.clear
                            .frame(width: 4, height: 4)
                    }
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: 12) {
            ReviewStatCard(
                title: "Check-ins",
                value: "\(checkedInDays)/7",
                icon: "checkmark.circle.fill",
                color: .green
            )

            ReviewStatCard(
                title: "Average",
                value: String(format: "%.1f", averageScore),
                icon: "chart.bar.fill",
                color: .blue
            )

            ReviewStatCard(
                title: "Perfect",
                value: "\(perfectDays)",
                icon: "star.fill",
                color: .yellow
            )
        }
    }

    // MARK: - Best Day

    private func bestDaySection(day: String, score: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.title)
                .foregroundStyle(.yellow)

            VStack(alignment: .leading, spacing: 4) {
                Text("Best Day")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Text("\(day) - Score \(score)")
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Motivation

    private var motivationSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title2)
                .foregroundStyle(Color.secondaryText)

            Text(motivationalQuote)
                .font(.body)
                .italic()
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.accentGreen.opacity(0.1), Color.accentGreen.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Action

    private var actionButton: some View {
        Button {
            HapticManager.shared.success()
            dismiss()
        } label: {
            Text("Let's Crush Next Week")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top)
    }

    // MARK: - Helpers

    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Review Stat Card

struct ReviewStatCard: View {
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
    WeeklyReviewView()
        .modelContainer(for: [DayEntry.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
