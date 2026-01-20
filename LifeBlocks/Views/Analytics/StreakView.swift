import SwiftUI

struct StreakView: View {
    let currentStreak: Int
    let longestStreak: Int
    var pathCategory: LifePathCategory = .custom
    var recentActivity: [DayEntry] = []
    var showShareButton: Bool = true

    private var isMilestone: Bool {
        [7, 14, 21, 30, 50, 100, 200, 365].contains(currentStreak)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Current streak (main focus)
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.3), lineWidth: 8)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: streakProgress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.title)
                            .foregroundStyle(.orange)

                        Text("\(currentStreak)")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                    }
                }

                Text("Current Streak")
                    .font(.headline)

                Text(streakMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Best streak
            if longestStreak > currentStreak {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Best: \(longestStreak) days")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1))
                .clipShape(Capsule())
            }

            // Next milestone
            if let milestone = nextMilestone {
                VStack(spacing: 4) {
                    Text("\(milestone - currentStreak) days to go")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("Next milestone: \(milestone) days")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.orange)
                }
            }

            // Share button for milestones
            if isMilestone && showShareButton {
                MilestoneShareButton(
                    streakDays: currentStreak,
                    pathCategory: pathCategory,
                    userName: "",
                    recentActivity: recentActivity
                )
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var streakProgress: CGFloat {
        guard let milestone = nextMilestone else { return 1.0 }
        let previousMilestone = milestones.last(where: { $0 < currentStreak }) ?? 0
        let range = milestone - previousMilestone
        let progress = currentStreak - previousMilestone
        return CGFloat(progress) / CGFloat(range)
    }

    private let milestones = [7, 14, 21, 30, 50, 100, 200, 365]

    private var nextMilestone: Int? {
        milestones.first(where: { $0 > currentStreak })
    }

    private var streakMessage: String {
        switch currentStreak {
        case 0:
            return "Start your streak today!"
        case 1:
            return "Day one - great start!"
        case 2...6:
            return "Building momentum!"
        case 7...13:
            return "A full week!"
        case 14...20:
            return "Two weeks strong!"
        case 21...29:
            return "Three weeks - habit forming!"
        case 30...49:
            return "A month of dedication!"
        case 50...99:
            return "Impressive consistency!"
        case 100...199:
            return "Triple digits!"
        case 200...364:
            return "Incredible commitment!"
        case 365...:
            return "A year of growth!"
        default:
            return "Keep it going!"
        }
    }
}

// Mini streak badge for compact display
struct StreakBadge: View {
    let streak: Int
    let size: BadgeSize

    enum BadgeSize {
        case small, medium, large

        var iconSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .body
            }
        }

        var textSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .subheadline
            }
        }

        var padding: CGFloat {
            switch self {
            case .small: return 4
            case .medium: return 6
            case .large: return 8
            }
        }
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(size.iconSize)

            Text("\(streak)")
                .font(size.textSize)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.orange)
        .padding(.horizontal, size.padding * 1.5)
        .padding(.vertical, size.padding)
        .background(Color.orange.opacity(0.15))
        .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 20) {
        StreakView(currentStreak: 12, longestStreak: 23)

        HStack {
            StreakBadge(streak: 5, size: .small)
            StreakBadge(streak: 12, size: .medium)
            StreakBadge(streak: 42, size: .large)
        }
    }
    .padding()
    .background(Color.gridBackground)
    .preferredColorScheme(.dark)
}
