import WidgetKit
import SwiftUI
import AppIntents

// MARK: - iOS 17+ Interactive Widget
/// Allows users to check in directly from the widget

// MARK: - Quick Check-In Intent

@available(iOS 17.0, *)
struct QuickCheckInIntent: AppIntent {
    static var title: LocalizedStringResource = "Quick Check In"
    static var description = IntentDescription("Mark today as checked in")

    func perform() async throws -> some IntentResult {
        // Update the check-in status
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard

        // Set today's score to at least 1 if not already set
        let currentScore = defaults.integer(forKey: "todayScore")
        if currentScore == 0 {
            defaults.set(1, forKey: "todayScore")
        }

        // Update last check-in date
        defaults.set(Date(), forKey: "lastCheckInDate")

        // Update streak
        let currentStreak = defaults.integer(forKey: "currentStreak")
        defaults.set(currentStreak + 1, forKey: "currentStreak")

        let longestStreak = defaults.integer(forKey: "longestStreak")
        if currentStreak + 1 > longestStreak {
            defaults.set(currentStreak + 1, forKey: "longestStreak")
        }

        // Store today's score in dayScores
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let todayKey = dateFormatter.string(from: Calendar.current.startOfDay(for: Date()))

        var dayScores: [String: Int] = [:]
        if let data = defaults.data(forKey: "dayScores"),
           let existing = try? JSONDecoder().decode([String: Int].self, from: data) {
            dayScores = existing
        }
        dayScores[todayKey] = max(dayScores[todayKey] ?? 0, 1)

        if let data = try? JSONEncoder().encode(dayScores) {
            defaults.set(data, forKey: "dayScores")
        }

        // Reload all widgets
        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

@available(iOS 17.0, *)
struct IncrementScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Increase Score"
    static var description = IntentDescription("Increase today's activity score")

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard

        let currentScore = defaults.integer(forKey: "todayScore")
        let newScore = min(currentScore + 1, 4)
        defaults.set(newScore, forKey: "todayScore")

        // Update last check-in date
        defaults.set(Date(), forKey: "lastCheckInDate")

        // Store in dayScores
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let todayKey = dateFormatter.string(from: Calendar.current.startOfDay(for: Date()))

        var dayScores: [String: Int] = [:]
        if let data = defaults.data(forKey: "dayScores"),
           let existing = try? JSONDecoder().decode([String: Int].self, from: data) {
            dayScores = existing
        }
        dayScores[todayKey] = newScore

        if let data = try? JSONEncoder().encode(dayScores) {
            defaults.set(data, forKey: "dayScores")
        }

        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

// MARK: - Interactive Widget Configuration

@available(iOS 17.0, *)
struct InteractiveCheckInWidget: Widget {
    let kind: String = "LifeBlocksInteractiveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LifeBlocksTimelineProvider()) { entry in
            InteractiveWidgetView(entry: entry)
                .containerBackground(Color(hex: "#0D1117"), for: .widget)
        }
        .configurationDisplayName("Quick Check-In")
        .description("Check in and track your progress right from your Home Screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Interactive Widget Views

@available(iOS 17.0, *)
struct InteractiveWidgetView: View {
    @Environment(\.widgetFamily) var family
    var entry: LifeBlocksEntry

    var body: some View {
        switch family {
        case .systemSmall:
            InteractiveSmallView(entry: entry)
        case .systemMedium:
            InteractiveMediumView(entry: entry)
        default:
            InteractiveSmallView(entry: entry)
        }
    }
}

@available(iOS 17.0, *)
struct InteractiveSmallView: View {
    var entry: LifeBlocksEntry
    let colorScheme = GridColorScheme.green

    var body: some View {
        VStack(spacing: 12) {
            // Streak display
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(entry.currentStreak)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            // Today's score indicator
            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(level < entry.todayScore ? colorScheme.color(for: entry.todayScore, isDarkMode: true) : Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                }
            }

            // Check-in button
            if entry.todayScore < 4 {
                Button(intent: IncrementScoreIntent()) {
                    HStack(spacing: 4) {
                        Image(systemName: entry.todayScore == 0 ? "checkmark.circle" : "plus.circle")
                            .font(.caption)
                        Text(entry.todayScore == 0 ? "Check In" : "Add")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            } else {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Complete!")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
    }
}

@available(iOS 17.0, *)
struct InteractiveMediumView: View {
    var entry: LifeBlocksEntry
    let colorScheme = GridColorScheme.green

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Stats
            VStack(alignment: .leading, spacing: 8) {
                // Streak
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(entry.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Weekly progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("This week")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { daysAgo in
                            let date = Calendar.current.date(byAdding: .day, value: -(6 - daysAgo), to: Date())!
                            let score = entry.dayScores[Calendar.current.startOfDay(for: date)] ?? 0

                            RoundedRectangle(cornerRadius: 3)
                                .fill(colorScheme.color(for: score, isDarkMode: true))
                                .frame(width: 14, height: 14)
                        }
                    }
                }

                Text(entry.motivationalMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Right side - Interactive check-in
            VStack(spacing: 8) {
                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                // Score level buttons
                VStack(spacing: 4) {
                    ForEach((1...4).reversed(), id: \.self) { level in
                        Button(intent: SetScoreIntent(level: level)) {
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(colorScheme.color(for: level, isDarkMode: true))
                                    .frame(width: 12, height: 12)
                                Text(scoreLevelText(level))
                                    .font(.system(size: 10))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(entry.todayScore == level ? Color.green.opacity(0.3) : Color.gray.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(width: 80)
        }
        .padding()
    }

    private func scoreLevelText(_ level: Int) -> String {
        switch level {
        case 1: return "Light"
        case 2: return "Moderate"
        case 3: return "Good"
        case 4: return "Excellent"
        default: return ""
        }
    }
}

// MARK: - Set Score Intent (for specific level)

@available(iOS 17.0, *)
struct SetScoreIntent: AppIntent {
    static var title: LocalizedStringResource = "Set Score Level"
    static var description = IntentDescription("Set today's activity to a specific level")

    @Parameter(title: "Level")
    var level: Int

    init() {
        self.level = 1
    }

    init(level: Int) {
        self.level = level
    }

    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app") ?? .standard

        defaults.set(level, forKey: "todayScore")
        defaults.set(Date(), forKey: "lastCheckInDate")

        // Update streak if first check-in of the day
        let lastCheckIn = defaults.object(forKey: "lastCheckInDate") as? Date
        let wasCheckedInToday = lastCheckIn.map { Calendar.current.isDateInToday($0) } ?? false

        if !wasCheckedInToday {
            let currentStreak = defaults.integer(forKey: "currentStreak")
            defaults.set(currentStreak + 1, forKey: "currentStreak")

            let longestStreak = defaults.integer(forKey: "longestStreak")
            if currentStreak + 1 > longestStreak {
                defaults.set(currentStreak + 1, forKey: "longestStreak")
            }
        }

        // Store in dayScores
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let todayKey = dateFormatter.string(from: Calendar.current.startOfDay(for: Date()))

        var dayScores: [String: Int] = [:]
        if let data = defaults.data(forKey: "dayScores"),
           let existing = try? JSONDecoder().decode([String: Int].self, from: data) {
            dayScores = existing
        }
        dayScores[todayKey] = level

        if let data = try? JSONEncoder().encode(dayScores) {
            defaults.set(data, forKey: "dayScores")
        }

        WidgetCenter.shared.reloadAllTimelines()

        return .result()
    }
}

// MARK: - Previews

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    InteractiveCheckInWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 0
    )
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 7,
        todayScore: 2
    )
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    InteractiveCheckInWidget()
} timeline: {
    LifeBlocksEntry(
        date: Date(),
        dayScores: [:],
        currentStreak: 14,
        todayScore: 3
    )
}
