import SwiftUI
import SwiftData

// MARK: - Insights View
/// Displays trend analysis, best time detection, and correlation insights

struct InsightsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var dayEntries: [DayEntry]
    @Query(filter: #Predicate<Habit> { $0.isActive }) private var habits: [Habit]

    private let analytics = AnalyticsService.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Daily Insights
                    dailyInsightsSection

                    // Best Time
                    bestTimeSection

                    // Weekday Trends
                    weekdayTrendsSection

                    // Weekly Progress
                    weeklyProgressSection

                    // Habit Correlations
                    if !habits.isEmpty {
                        correlationsSection
                    }

                    // Premium upsell if needed
                    if !AppSettings.shared.isPremium {
                        premiumUpsell
                    }
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Daily Insights Section

    private var dailyInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Your Insights", icon: "lightbulb.fill")

            let insights = analytics.generateDailyInsights(entries: dayEntries, habits: habits)

            if insights.isEmpty {
                EmptyInsightCard(message: "Check in for a few more days to unlock personalized insights")
            } else {
                ForEach(insights, id: \.message) { insight in
                    InsightCard(
                        message: insight.message,
                        icon: insight.icon,
                        color: Color(hex: insight.color)
                    )
                }
            }
        }
    }

    // MARK: - Best Time Section

    private var bestTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Best Check-in Time", icon: "clock.fill")

            if let bestTime = analytics.getBestCheckInTime() {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(bestTime.timeString)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.accentGreen)

                            Text("Your most consistent time")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }

                        Spacer()

                        CircularProgressView(percentage: bestTime.percentage, color: .accentGreen)
                    }

                    // Time distribution chart
                    TimeDistributionChart(slots: analytics.getCheckInTimeDistribution())
                }
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                EmptyInsightCard(message: "Check in a few more times to see your best time")
            }
        }
    }

    // MARK: - Weekday Trends Section

    private var weekdayTrendsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weekday Performance", icon: "calendar")

            let trends = analytics.getWeekdayTrends(from: dayEntries)

            if !trends.isEmpty {
                VStack(spacing: 16) {
                    // Bar chart
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(trends) { trend in
                            VStack(spacing: 4) {
                                Text(String(format: "%.1f", trend.averageScore))
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondaryText)

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor(for: trend.averageScore))
                                    .frame(width: 32, height: max(20, CGFloat(trend.averageScore) * 20))

                                Text(trend.shortName)
                                    .font(.caption2)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    }
                    .frame(height: 120)

                    // Best and worst days
                    if let best = trends.max(by: { $0.averageScore < $1.averageScore }),
                       let worst = trends.min(by: { $0.averageScore < $1.averageScore }) {
                        HStack {
                            DayStatPill(label: "Best", day: best.weekdayName, color: .green)
                            Spacer()
                            DayStatPill(label: "Needs work", day: worst.weekdayName, color: .orange)
                        }
                    }
                }
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                EmptyInsightCard(message: "Track for a week to see your weekday patterns")
            }
        }
    }

    // MARK: - Weekly Progress Section

    private var weeklyProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Weekly Trend", icon: "chart.line.uptrend.xyaxis")

            let weeklyData = analytics.getWeeklyCheckInTrend(from: dayEntries)

            VStack(spacing: 16) {
                // Sparkline
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(weeklyData.enumerated()), id: \.offset) { index, data in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(index == weeklyData.count - 1 ? Color.accentGreen : Color.accentGreen.opacity(0.5))
                                .frame(width: 30, height: max(10, CGFloat(data.checkIns) * 10))
                        }
                    }
                }
                .frame(height: 80)

                HStack {
                    Text("8 weeks ago")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                    Spacer()
                    Text("This week")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                }

                // Trend indicator
                let trend = calculateTrend(from: weeklyData)
                HStack {
                    Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .foregroundStyle(trend >= 0 ? .green : .red)
                    Text(trend >= 0 ? "Trending up!" : "Room to improve")
                        .font(.subheadline)
                        .foregroundStyle(trend >= 0 ? .green : Color.secondaryText)
                }
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Correlations Section

    private var correlationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Habit Connections", icon: "link")

            let correlations = analytics.getHabitCorrelations(habits: habits, entries: dayEntries)

            if correlations.isEmpty {
                EmptyInsightCard(message: "Track multiple habits to discover connections")
            } else {
                ForEach(correlations.prefix(3)) { correlation in
                    CorrelationCard(correlation: correlation)
                }
            }
        }
    }

    // MARK: - Premium Upsell

    private var premiumUpsell: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.doc.horizontal.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.accentGreen)

            Text("Unlock Advanced Analytics")
                .font(.headline)

            Text("Get deeper insights, habit correlations, and trend predictions with Premium")
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)

            Button("Learn More") {
                // Navigate to premium
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color.accentGreen)
            .clipShape(Capsule())
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Helpers

    private func barColor(for score: Double) -> Color {
        if score >= 3 { return .green }
        if score >= 2 { return .yellow }
        if score >= 1 { return .orange }
        return .red.opacity(0.5)
    }

    private func calculateTrend(from data: [(week: Int, checkIns: Int)]) -> Double {
        guard data.count >= 4 else { return 0 }
        let recentAvg = Double(data.suffix(4).map(\.checkIns).reduce(0, +)) / 4
        let olderAvg = Double(data.prefix(4).map(\.checkIns).reduce(0, +)) / 4
        return recentAvg - olderAvg
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentGreen)
            Text(title)
                .font(.headline)
        }
    }
}

struct InsightCard: View {
    let message: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 32)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)

            Spacer()
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct EmptyInsightCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "hourglass")
                .foregroundStyle(Color.secondaryText)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct CircularProgressView: View {
    let percentage: Double
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
                .frame(width: 60, height: 60)

            Circle()
                .trim(from: 0, to: percentage / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))

            Text("\(Int(percentage))%")
                .font(.caption)
                .fontWeight(.bold)
        }
    }
}

struct TimeDistributionChart: View {
    let slots: [AnalyticsService.TimeSlot]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(slots) { slot in
                    VStack(spacing: 2) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accentGreen.opacity(0.3 + slot.percentage / 200))
                            .frame(width: 16, height: max(4, CGFloat(slot.percentage)))

                        if slot.hour % 6 == 0 {
                            Text("\(slot.hour)")
                                .font(.system(size: 8))
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                }
            }
        }
        .frame(height: 60)
    }
}

struct DayStatPill: View {
    let label: String
    let day: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.secondaryText)
            Text(day)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct CorrelationCard: View {
    let correlation: AnalyticsService.CorrelationInsight

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: correlation.isPositive ? "link" : "arrow.left.arrow.right")
                    .foregroundStyle(correlation.isPositive ? .green : .orange)

                Text("\(correlation.habit1) & \(correlation.habit2)")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Text(correlation.strength)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
            }

            Text(correlation.message)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    InsightsView()
        .modelContainer(for: [DayEntry.self, Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
