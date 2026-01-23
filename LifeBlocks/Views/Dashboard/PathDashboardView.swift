import SwiftUI
import SwiftData

struct PathDashboardView: View {
    @Query private var dayEntries: [DayEntry]
    @State private var showingQuoteDetail = false
    @State private var currentQuote: String = ""
    @State private var showingLifeGoals = false

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

            // Life Goals quick access
            lifeGoalsButton

            // Level progress
            levelProgress
        }
        .sheet(isPresented: $showingLifeGoals) {
            LifeGoalsView()
        }
    }

    // MARK: - Life Goals Button

    private var lifeGoalsButton: some View {
        Button {
            HapticManager.shared.lightTap()
            showingLifeGoals = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.orange)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Life Goals")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("Short & long term vision")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                let goalCount = AppSettings.shared.lifeGoals.filter { !$0.isCompleted }.count
                if goalCount > 0 {
                    Text("\(goalCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Path Header (Simplified)

    private var pathHeader: some View {
        HStack(spacing: 12) {
            // Simpler icon - just colored circle with icon
            Image(systemName: pathCategory.icon)
                .font(.title3)
                .foregroundStyle(pathCategory.color)

            Text(pathCategory.displayName)
                .font(.headline)

            Spacer()

            // Days counter - cleaner
            Text("\(daysOnPath) days")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Motivation Card (Simplified)

    private var motivationCard: some View {
        Button {
            refreshQuote()
        } label: {
            Text(currentQuote.isEmpty ? getRandomQuote() : currentQuote)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .onAppear {
            if currentQuote.isEmpty {
                currentQuote = getRandomQuote()
            }
        }
    }

    // MARK: - Level Progress (Simplified)

    private var levelProgress: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Level \(pathProgress.level)")
                    .font(.caption)
                    .fontWeight(.medium)

                Spacer()

                Text("Level \(pathProgress.level + 1)")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.cardBackground)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(pathCategory.color)
                        .frame(width: geometry.size.width * pathProgress.progressToNextLevel, height: 6)
                }
            }
            .frame(height: 6)
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

// MARK: - Quick Action Card (Simplified)

struct QuickActionCard: View {
    let hasCheckedInToday: Bool
    let action: () -> Void

    var body: some View {
        Button {
            HapticManager.shared.mediumTap()
            action()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: hasCheckedInToday ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentGreen)

                Text(hasCheckedInToday ? "Done for today" : "Check in")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Milestone Celebration View (Simplified)

struct MilestoneCelebrationView: View {
    let milestone: Int
    let pathCategory: LifePathCategory
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Simple celebration
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundStyle(pathCategory.color)

            VStack(spacing: 12) {
                Text("\(milestone) Days")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Milestone reached")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()

            Button {
                onDismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(pathCategory.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
