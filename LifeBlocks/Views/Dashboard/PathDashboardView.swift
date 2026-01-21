import SwiftUI
import SwiftData

struct PathDashboardView: View {
    @Query private var dayEntries: [DayEntry]
    @State private var showingQuoteDetail = false
    @State private var currentQuote: String = ""

    private var lifePath: UserLifePath? {
        AppSettings.shared.userLifePath
    }

    private var pathCategory: LifePathCategory {
        lifePath?.selectedPath ?? .custom
    }

    private var daysOnPath: Int {
        guard let startDate = AppSettings.shared.pathStartDate else { return 0 }
        return max(0, Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0)
    }

    private var pathProgress: PathProgress {
        PathProgress(
            daysOnPath: daysOnPath,
            currentStreak: AppSettings.shared.currentStreak,
            totalCheckIns: dayEntries.filter { $0.checkedIn }.count,
            averageScore: calculateAverageScore(),
            habitsCompleted: dayEntries.reduce(0) { $0 + ($1.checkedIn ? 1 : 0) }
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            // Path header with level
            pathHeader

            // Daily motivation card
            motivationCard

            // Level progress
            levelProgress
        }
    }

    // MARK: - Path Header

    private var pathHeader: some View {
        HStack(spacing: 12) {
            // Path icon
            ZStack {
                Circle()
                    .fill(pathCategory.color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: pathCategory.icon)
                    .font(.title2)
                    .foregroundStyle(pathCategory.color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pathCategory.displayName)
                    .font(.headline)

                HStack(spacing: 4) {
                    Text("Level \(pathProgress.level)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(pathCategory.color)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(pathProgress.levelTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Days counter
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(daysOnPath)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(pathCategory.color)

                Text("days")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Motivation Card

    private var motivationCard: some View {
        Button {
            refreshQuote()
            showingQuoteDetail = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "quote.opening")
                    .font(.title3)
                    .foregroundStyle(pathCategory.color.opacity(0.7))

                Text(currentQuote.isEmpty ? getRandomQuote() : currentQuote)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                Spacer()

                Image(systemName: "arrow.clockwise")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [pathCategory.color.opacity(0.1), pathCategory.color.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onAppear {
            if currentQuote.isEmpty {
                currentQuote = getRandomQuote()
            }
        }
    }

    // MARK: - Level Progress

    private var levelProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(pathProgress.level)")
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Text("Level \(pathProgress.level + 1)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.borderColor)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [pathCategory.color, pathCategory.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * pathProgress.progressToNextLevel, height: 8)
                }
            }
            .frame(height: 8)

            // Next milestone hint
            if let nextMilestone = getNextMilestone() {
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.caption2)
                        .foregroundStyle(pathCategory.color)

                    Text(nextMilestone)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Helpers

    private func calculateAverageScore() -> Double {
        let checkedInEntries = dayEntries.filter { $0.checkedIn }
        guard !checkedInEntries.isEmpty else { return 0 }
        let total = checkedInEntries.reduce(0) { $0 + $1.totalScore }
        return Double(total) / Double(checkedInEntries.count)
    }

    private func getRandomQuote() -> String {
        pathCategory.motivationalQuotes.randomElement() ?? "Keep going!"
    }

    private func refreshQuote() {
        var newQuote = getRandomQuote()
        // Make sure we get a different quote
        while newQuote == currentQuote && pathCategory.motivationalQuotes.count > 1 {
            newQuote = getRandomQuote()
        }
        withAnimation {
            currentQuote = newQuote
        }
    }

    private func getNextMilestone() -> String? {
        let milestones = [7, 14, 21, 30, 50, 100, 200, 365]
        if let next = milestones.first(where: { $0 > daysOnPath }) {
            let remaining = next - daysOnPath
            return "\(remaining) days to \(next)-day milestone"
        }
        return nil
    }
}

// MARK: - Quick Action Card for impulse check-in

struct QuickActionCard: View {
    let hasCheckedInToday: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.mediumTap()
            action()
        } label: {
            HStack(spacing: 16) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(hasCheckedInToday ? Color.accentGreen.opacity(0.2) : Color.accentGreen)
                        .frame(width: 56, height: 56)

                    Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "plus")
                        .font(.title2)
                        .foregroundStyle(hasCheckedInToday ? Color.accentGreen : .white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(hasCheckedInToday ? "Great job today!" : "Check in now")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(hasCheckedInToday ? "Tap to update your check-in" : "30 seconds to a better you")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if !hasCheckedInToday {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.cardBackground)
                    .shadow(color: hasCheckedInToday ? .clear : Color.accentGreen.opacity(0.3), radius: 8, y: 4)
            )
            .overlay {
                if !hasCheckedInToday {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.accentGreen.opacity(0.5), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Milestone Celebration View

struct MilestoneCelebrationView: View {
    let milestone: Int
    let pathCategory: LifePathCategory
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Celebration icon
            ZStack {
                Circle()
                    .fill(pathCategory.color.opacity(0.2))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(pathCategory.color.opacity(0.3))
                    .frame(width: 100, height: 100)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(pathCategory.color)
            }

            VStack(spacing: 16) {
                Text("Milestone Reached!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(milestone) Days")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(pathCategory.color)

                Text("You've been on your \(pathCategory.displayName) journey for \(milestone) days. That's incredible dedication!")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Share button
            Button {
                // Share action
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Achievement")
                }
                .font(.headline)
                .foregroundStyle(pathCategory.color)
                .padding()
                .background(pathCategory.color.opacity(0.1))
                .clipShape(Capsule())
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(pathCategory.color)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.gridBackground.ignoresSafeArea())
    }
}

#Preview {
    VStack(spacing: 16) {
        PathDashboardView()

        QuickActionCard(hasCheckedInToday: false) {
            print("Check in")
        }

        QuickActionCard(hasCheckedInToday: true) {
            print("Update")
        }
    }
    .padding()
    .background(Color.gridBackground)
    .preferredColorScheme(.dark)
}
