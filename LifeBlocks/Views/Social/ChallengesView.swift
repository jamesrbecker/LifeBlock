import SwiftUI
import SwiftData

// MARK: - Challenges View

struct ChallengesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Challenge.endDate) private var challenges: [Challenge]
    @ObservedObject private var subscription = SubscriptionStatus.shared

    @State private var showingAvailableChallenges = false
    @State private var showingPremium = false

    private var activeChallenges: [Challenge] {
        challenges.filter { $0.isActive && !$0.isExpired && !$0.isCompleted }
    }

    private var completedChallenges: [Challenge] {
        challenges.filter { $0.isCompleted }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if subscription.canAccessChallenges {
                        // Header stats
                        headerStats

                        // Active challenges
                        if !activeChallenges.isEmpty {
                            challengeSection(title: "Active Challenges", challenges: activeChallenges, showProgress: true)
                        }

                        // Join new challenge button
                        joinChallengeButton

                        // Completed challenges
                        if !completedChallenges.isEmpty {
                            challengeSection(title: "Completed", challenges: completedChallenges, showProgress: false)
                        }

                        // Empty state
                        if challenges.isEmpty {
                            emptyState
                        }
                    } else {
                        // Premium required
                        premiumRequired
                    }
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAvailableChallenges) {
                AvailableChallengesSheet { challenge in
                    joinChallenge(challenge)
                }
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
        }
    }

    // MARK: - Premium Required

    private var premiumRequired: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "flag.checkered.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple)

            VStack(spacing: 8) {
                Text("Challenges")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Compete with others, join challenges, and stay motivated on your journey.")
                    .font(.body)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                FeatureRow(icon: "flame.fill", text: "Join community challenges", color: .orange)
                FeatureRow(icon: "trophy.fill", text: "Earn points and badges", color: .yellow)
                FeatureRow(icon: "person.3.fill", text: "Compete with friends", color: .blue)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                showingPremium = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Unlock with Premium")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Header Stats

    private var headerStats: some View {
        HStack(spacing: 16) {
            ChallengeStatBox(
                value: "\(activeChallenges.count)",
                label: "Active",
                icon: "flame.fill",
                color: .orange
            )

            ChallengeStatBox(
                value: "\(completedChallenges.count)",
                label: "Done",
                icon: "trophy.fill",
                color: .yellow
            )

            ChallengeStatBox(
                value: "\(calculateTotalPoints())",
                label: "Points",
                icon: "star.fill",
                color: .purple
            )
        }
    }

    // MARK: - Challenge Section

    private func challengeSection(title: String, challenges: [Challenge], showProgress: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.secondaryText)

            ForEach(challenges) { challenge in
                ChallengeCard(challenge: challenge, showProgress: showProgress)
            }
        }
    }

    // MARK: - Join Challenge Button

    private var joinChallengeButton: some View {
        Button {
            HapticManager.shared.mediumTap()
            showingAvailableChallenges = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Join a Challenge")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentGreen)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.checkered")
                .font(.system(size: 60))
                .foregroundStyle(Color.secondaryText)

            Text("No Active Challenges")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Join a challenge to compete with others and stay motivated!")
                .font(.body)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Helper Methods

    private func joinChallenge(_ template: Challenge) {
        let newChallenge = Challenge(
            title: template.title,
            description: template.challengeDescription,
            type: template.type,
            goal: template.goal,
            startDate: Date(),
            endDate: template.endDate,
            isGlobal: template.isGlobal
        )
        modelContext.insert(newChallenge)
        HapticManager.shared.success()
    }

    private func calculateTotalPoints() -> Int {
        completedChallenges.count * 100
    }
}

// MARK: - Challenge Card

struct ChallengeCard: View {
    let challenge: Challenge
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundStyle(challenge.isCompleted ? .yellow : .accentGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(.headline)

                    Text(challenge.statusText)
                        .font(.caption)
                        .foregroundStyle(statusColor)
                }

                Spacer()

                if challenge.isGlobal {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                        Text("\(challenge.participantCount)")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Capsule())
                }
            }

            // Description
            Text(challenge.challengeDescription)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            // Progress bar
            if showProgress {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(challenge.progress) / \(challenge.goal)")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)

                        Spacer()

                        Text("\(Int(challenge.progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentGreen)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentGreen)
                                .frame(width: geometry.size.width * challenge.progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }

            // Completed badge
            if challenge.isCompleted {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.yellow)
                    Text("Challenge Completed!")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.yellow)
                    Spacer()
                    Text("+100 pts")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.purple)
                }
                .padding(8)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var statusColor: Color {
        if challenge.isCompleted {
            return .yellow
        } else if challenge.isExpired {
            return .red
        } else if challenge.daysRemaining <= 2 {
            return .orange
        } else {
            return .secondary
        }
    }
}

// MARK: - Challenge Stat Box

struct ChallengeStatBox: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Available Challenges Sheet

struct AvailableChallengesSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onJoin: (Challenge) -> Void

    private let availableChallenges = Challenge.availableChallenges

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(availableChallenges, id: \.title) { challenge in
                        AvailableChallengeRow(challenge: challenge) {
                            onJoin(challenge)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Join Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Available Challenge Row

struct AvailableChallengeRow: View {
    let challenge: Challenge
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentGreen)

                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(.headline)

                    Text(challenge.type.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if challenge.isGlobal {
                    Label("Global", systemImage: "globe")
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .clipShape(Capsule())
                }
            }

            Text(challenge.challengeDescription)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            HStack {
                Label("Goal: \(challenge.goal)", systemImage: "target")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Spacer()

                Label("\(challenge.daysRemaining) days", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Button {
                HapticManager.shared.mediumTap()
                onJoin()
            } label: {
                Text("Join Challenge")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.accentGreen)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    ChallengesView()
        .modelContainer(for: Challenge.self, inMemory: true)
        .preferredColorScheme(.dark)
}
