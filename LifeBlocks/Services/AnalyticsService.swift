import Foundation
import SwiftData

// MARK: - Analytics Service
/// Provides trend analysis, best time detection, and correlation insights

final class AnalyticsService {
    static let shared = AnalyticsService()

    private init() {}

    // MARK: - Best Time Detection

    struct TimeSlot: Identifiable {
        let id = UUID()
        let hour: Int
        let count: Int
        let percentage: Double

        var timeString: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "h a"
            var components = DateComponents()
            components.hour = hour
            if let date = Calendar.current.date(from: components) {
                return formatter.string(from: date)
            }
            return "\(hour):00"
        }
    }

    /// Analyzes check-in times to find the best time for the user
    func getBestCheckInTime() -> TimeSlot? {
        let times = AppSettings.shared.checkInTimes
        guard !times.isEmpty else { return nil }

        // Group by hour
        var hourCounts: [Int: Int] = [:]
        for time in times {
            let hour = Calendar.current.component(.hour, from: time)
            hourCounts[hour, default: 0] += 1
        }

        // Find most common hour
        guard let (bestHour, count) = hourCounts.max(by: { $0.value < $1.value }) else {
            return nil
        }

        let percentage = Double(count) / Double(times.count) * 100
        return TimeSlot(hour: bestHour, count: count, percentage: percentage)
    }

    /// Returns distribution of check-in times by hour
    func getCheckInTimeDistribution() -> [TimeSlot] {
        let times = AppSettings.shared.checkInTimes
        guard !times.isEmpty else { return [] }

        var hourCounts: [Int: Int] = [:]
        for time in times {
            let hour = Calendar.current.component(.hour, from: time)
            hourCounts[hour, default: 0] += 1
        }

        let total = times.count
        return hourCounts.map { hour, count in
            TimeSlot(hour: hour, count: count, percentage: Double(count) / Double(total) * 100)
        }.sorted { $0.hour < $1.hour }
    }

    // MARK: - Trend Analysis

    struct WeekdayTrend: Identifiable {
        let id = UUID()
        let weekday: Int  // 1 = Sunday, 7 = Saturday
        let averageScore: Double
        let checkInRate: Double

        var weekdayName: String {
            let formatter = DateFormatter()
            return formatter.weekdaySymbols[weekday - 1]
        }

        var shortName: String {
            let formatter = DateFormatter()
            return formatter.shortWeekdaySymbols[weekday - 1]
        }
    }

    /// Analyzes which days of the week user performs best
    func getWeekdayTrends(from entries: [DayEntry]) -> [WeekdayTrend] {
        guard !entries.isEmpty else { return [] }

        var weekdayData: [Int: (totalScore: Int, checkIns: Int, days: Int)] = [:]

        // Initialize all weekdays
        for day in 1...7 {
            weekdayData[day] = (0, 0, 0)
        }

        // Aggregate data
        for entry in entries {
            let weekday = Calendar.current.component(.weekday, from: entry.date)
            var data = weekdayData[weekday]!
            data.totalScore += entry.totalScore
            data.checkIns += entry.checkedIn ? 1 : 0
            data.days += 1
            weekdayData[weekday] = data
        }

        return weekdayData.map { weekday, data in
            let avgScore = data.days > 0 ? Double(data.totalScore) / Double(data.days) : 0
            let checkInRate = data.days > 0 ? Double(data.checkIns) / Double(data.days) * 100 : 0
            return WeekdayTrend(weekday: weekday, averageScore: avgScore, checkInRate: checkInRate)
        }.sorted { $0.weekday < $1.weekday }
    }

    /// Calculates streak consistency score (0-100)
    func getConsistencyScore(from entries: [DayEntry]) -> Int {
        guard entries.count >= 7 else { return 0 }

        let last30Days = entries.filter {
            let daysDiff = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 0
            return daysDiff <= 30
        }

        let checkIns = last30Days.filter { $0.checkedIn }.count
        let total = min(last30Days.count, 30)
        guard total > 0 else { return 0 }

        return Int((Double(checkIns) / Double(total)) * 100)
    }

    /// Returns weekly check-in counts for the last 8 weeks
    func getWeeklyCheckInTrend(from entries: [DayEntry]) -> [(week: Int, checkIns: Int)] {
        var weeklyData: [Int: Int] = [:]

        for entry in entries {
            if entry.checkedIn {
                let weeksAgo = Calendar.current.dateComponents([.weekOfYear], from: entry.date, to: Date()).weekOfYear ?? 0
                if weeksAgo >= 0 && weeksAgo < 8 {
                    weeklyData[weeksAgo, default: 0] += 1
                }
            }
        }

        return (0..<8).map { week in
            (week: week, checkIns: weeklyData[week] ?? 0)
        }.reversed()
    }

    // MARK: - Correlation Insights

    struct CorrelationInsight: Identifiable {
        let id = UUID()
        let habit1: String
        let habit2: String
        let correlation: Double  // -1 to 1
        let message: String

        var isPositive: Bool { correlation > 0 }
        var strength: String {
            let abs = Swift.abs(correlation)
            if abs > 0.7 { return "strong" }
            if abs > 0.4 { return "moderate" }
            return "weak"
        }
    }

    /// Finds correlations between habits
    func getHabitCorrelations(habits: [Habit], entries: [DayEntry]) -> [CorrelationInsight] {
        guard habits.count >= 2, entries.count >= 14 else { return [] }

        var insights: [CorrelationInsight] = []

        // Compare each pair of habits
        for i in 0..<habits.count {
            for j in (i+1)..<habits.count {
                let habit1 = habits[i]
                let habit2 = habits[j]

                let correlation = calculateCorrelation(habit1: habit1, habit2: habit2, entries: entries)

                if abs(correlation) > 0.3 {  // Only show meaningful correlations
                    let message = generateCorrelationMessage(habit1: habit1.name, habit2: habit2.name, correlation: correlation)
                    insights.append(CorrelationInsight(
                        habit1: habit1.name,
                        habit2: habit2.name,
                        correlation: correlation,
                        message: message
                    ))
                }
            }
        }

        return insights.sorted { abs($0.correlation) > abs($1.correlation) }
    }

    private func calculateCorrelation(habit1: Habit, habit2: Habit, entries: [DayEntry]) -> Double {
        var habit1Scores: [Double] = []
        var habit2Scores: [Double] = []

        for entry in entries {
            let score1 = Double(habit1.completionLevel(for: entry.date))
            let score2 = Double(habit2.completionLevel(for: entry.date))
            habit1Scores.append(score1)
            habit2Scores.append(score2)
        }

        return pearsonCorrelation(habit1Scores, habit2Scores)
    }

    private func pearsonCorrelation(_ x: [Double], _ y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0 }

        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map { $0 * $1 }.reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)

        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))

        guard denominator != 0 else { return 0 }
        return numerator / denominator
    }

    private func generateCorrelationMessage(habit1: String, habit2: String, correlation: Double) -> String {
        let strength = abs(correlation) > 0.7 ? "much" : "somewhat"

        if correlation > 0 {
            return "When you complete \(habit1), you're \(strength) more likely to complete \(habit2)"
        } else {
            return "Days you focus on \(habit1), you \(strength) less often do \(habit2)"
        }
    }

    // MARK: - Overall Insights

    struct DailyInsight {
        let type: InsightType
        let message: String
        let icon: String
        let color: String

        enum InsightType {
            case bestDay
            case bestTime
            case correlation
            case streak
            case consistency
        }
    }

    /// Generates personalized daily insights
    func generateDailyInsights(entries: [DayEntry], habits: [Habit]) -> [DailyInsight] {
        var insights: [DailyInsight] = []

        // Best day insight
        let weekdayTrends = getWeekdayTrends(from: entries)
        if let bestDay = weekdayTrends.max(by: { $0.averageScore < $1.averageScore }), bestDay.averageScore > 0 {
            insights.append(DailyInsight(
                type: .bestDay,
                message: "Your best day is \(bestDay.weekdayName) with an average score of \(String(format: "%.1f", bestDay.averageScore))",
                icon: "calendar.badge.checkmark",
                color: "#30A14E"
            ))
        }

        // Best time insight
        if let bestTime = getBestCheckInTime() {
            insights.append(DailyInsight(
                type: .bestTime,
                message: "You're most consistent checking in around \(bestTime.timeString) (\(Int(bestTime.percentage))% of check-ins)",
                icon: "clock.fill",
                color: "#0366D6"
            ))
        }

        // Streak insight
        let currentStreak = AppSettings.shared.currentStreak
        let longestStreak = AppSettings.shared.longestStreak
        if currentStreak > 0 && currentStreak < longestStreak {
            let toGo = longestStreak - currentStreak
            insights.append(DailyInsight(
                type: .streak,
                message: "You're \(toGo) days away from beating your longest streak of \(longestStreak) days!",
                icon: "flame.fill",
                color: "#FF6B35"
            ))
        }

        // Consistency insight
        let consistency = getConsistencyScore(from: entries)
        if consistency >= 80 {
            insights.append(DailyInsight(
                type: .consistency,
                message: "Amazing! Your 30-day consistency score is \(consistency)%",
                icon: "star.fill",
                color: "#FFD700"
            ))
        } else if consistency < 50 {
            insights.append(DailyInsight(
                type: .consistency,
                message: "Tip: Try checking in at the same time each day to build consistency",
                icon: "lightbulb.fill",
                color: "#FFC107"
            ))
        }

        return insights
    }
}
