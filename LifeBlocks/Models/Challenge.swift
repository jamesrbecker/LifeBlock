import Foundation
import SwiftData

// MARK: - Challenge Model
/// Represents a time-limited challenge users can participate in

@Model
final class Challenge {
    var id: UUID
    var title: String
    var challengeDescription: String
    var type: ChallengeType
    var goal: Int
    var startDate: Date
    var endDate: Date
    var isActive: Bool
    var isCompleted: Bool
    var progress: Int
    var createdAt: Date

    // For community challenges
    var isGlobal: Bool
    var participantCount: Int

    init(
        title: String,
        description: String,
        type: ChallengeType,
        goal: Int,
        startDate: Date,
        endDate: Date,
        isGlobal: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.challengeDescription = description
        self.type = type
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.isActive = true
        self.isCompleted = false
        self.progress = 0
        self.createdAt = Date()
        self.isGlobal = isGlobal
        self.participantCount = isGlobal ? Int.random(in: 500...5000) : 1
    }

    var progressPercentage: Double {
        guard goal > 0 else { return 0 }
        return min(Double(progress) / Double(goal), 1.0)
    }

    var daysRemaining: Int {
        let remaining = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0
        return max(0, remaining)
    }

    var isExpired: Bool {
        Date() > endDate
    }

    var statusText: String {
        if isCompleted {
            return "Completed!"
        } else if isExpired {
            return "Expired"
        } else if daysRemaining == 0 {
            return "Last day!"
        } else if daysRemaining == 1 {
            return "1 day left"
        } else {
            return "\(daysRemaining) days left"
        }
    }
}

// MARK: - Challenge Type

enum ChallengeType: String, Codable, CaseIterable {
    case streak = "streak"
    case checkIns = "check_ins"
    case perfectWeek = "perfect_week"
    case earlyBird = "early_bird"
    case nightOwl = "night_owl"
    case consistency = "consistency"

    var displayName: String {
        switch self {
        case .streak: return "Streak"
        case .checkIns: return "Check-ins"
        case .perfectWeek: return "Perfect Week"
        case .earlyBird: return "Early Bird"
        case .nightOwl: return "Night Owl"
        case .consistency: return "Consistency"
        }
    }

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .checkIns: return "checkmark.circle.fill"
        case .perfectWeek: return "star.fill"
        case .earlyBird: return "sunrise.fill"
        case .nightOwl: return "moon.fill"
        case .consistency: return "chart.line.uptrend.xyaxis"
        }
    }

    var description: String {
        switch self {
        case .streak: return "Maintain your streak for the target days"
        case .checkIns: return "Complete the target number of check-ins"
        case .perfectWeek: return "Check in every day for a week"
        case .earlyBird: return "Check in before 9 AM"
        case .nightOwl: return "Check in after 9 PM"
        case .consistency: return "Keep your average score above target"
        }
    }
}

// MARK: - Predefined Challenges

extension Challenge {
    static var weeklyChallenge: Challenge {
        Challenge(
            title: "7-Day Streak",
            description: "Check in every day for 7 days straight",
            type: .streak,
            goal: 7,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isGlobal: true
        )
    }

    static var monthlyCheckIn: Challenge {
        Challenge(
            title: "30 Check-ins",
            description: "Complete 30 check-ins this month",
            type: .checkIns,
            goal: 30,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())!,
            isGlobal: true
        )
    }

    static var perfectWeek: Challenge {
        Challenge(
            title: "Perfect Week",
            description: "Score at least 3 points every day this week",
            type: .perfectWeek,
            goal: 7,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            isGlobal: true
        )
    }

    static var earlyBirdChallenge: Challenge {
        Challenge(
            title: "Early Bird",
            description: "Check in before 9 AM for 5 days",
            type: .earlyBird,
            goal: 5,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())!,
            isGlobal: false
        )
    }

    static var consistencyChallenge: Challenge {
        Challenge(
            title: "Consistency King",
            description: "Maintain a streak of 21 days",
            type: .consistency,
            goal: 21,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!,
            isGlobal: true
        )
    }

    static var availableChallenges: [Challenge] {
        [weeklyChallenge, monthlyCheckIn, perfectWeek, earlyBirdChallenge, consistencyChallenge]
    }
}
