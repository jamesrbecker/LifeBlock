import SwiftUI
import SwiftData

// =============================================================================
// MARK: - ChallengesView.swift
// =============================================================================
/// The main view for displaying and managing habit challenges.
///
/// ## Overview
/// Challenges are timed competitions where users try to achieve specific goals
/// (like maintaining a streak for X days or completing Y check-ins). They add
/// a gamification element to encourage consistency.
///
/// ## Premium Feature
/// Challenges are a premium-only feature. Free users see a paywall explaining
/// the benefits and encouraging them to upgrade.
///
/// ## Challenge Types
/// - **Streak challenges**: Maintain a daily streak for a set number of days
/// - **Check-in challenges**: Complete a certain number of check-ins
/// - **Points challenges**: Earn a target number of points
///
/// ## Challenge States
/// - **Active**: Currently in progress, not yet completed or expired
/// - **Completed**: Goal was achieved within the time limit
/// - **Expired**: Time ran out before goal was achieved
///
/// ## Global vs Personal
/// - **Global challenges**: Community-wide, shows participant count
/// - **Personal challenges**: Just for you, private progress

struct ChallengesView: View {

    // MARK: - Environment

    /// Dismiss action to close this sheet
    @Environment(\.dismiss) private var dismiss

    /// SwiftData model context for saving/deleting challenges
    @Environment(\.modelContext) private var modelContext

    /// All challenges stored in SwiftData, sorted by end date (soonest first)
    @Query(sort: \Challenge.endDate) private var challenges: [Challenge]

    /// Subscription status to check if user has premium access
    @ObservedObject private var subscription = SubscriptionStatus.shared

    // MARK: - State

    /// Controls whether the "Join a Challenge" sheet is displayed
    @State private var showingAvailableChallenges = false

    /// Controls whether the premium upgrade sheet is displayed
    @State private var showingPremium = false

    // MARK: - Computed Properties

    /// Filters to only show active, non-expired, non-completed challenges
    /// These are challenges the user is currently working on
    private var activeChallenges: [Challenge] {
        challenges.filter { $0.isActive && !$0.isExpired && !$0.isCompleted }
    }

    /// Filters to only show completed challenges
    /// Used to display the user's achievements
    private var completedChallenges: [Challenge] {
        challenges.filter { $0.isCompleted }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // ═══════════════════════════════════════════════════════════
                    // PREMIUM CHECK
                    // ═══════════════════════════════════════════════════════════
                    // Only premium users can access challenges
                    // Free users see a paywall with upgrade option
                    if subscription.canAccessChallenges {
                        // ═══════════════════════════════════════════════════════
                        // HEADER STATS
                        // ═══════════════════════════════════════════════════════
                        // Shows quick overview: Active count, Completed count, Points
                        headerStats

                        // ═══════════════════════════════════════════════════════
                        // ACTIVE CHALLENGES SECTION
                        // ═══════════════════════════════════════════════════════
                        // Shows challenges currently in progress with progress bars
                        if !activeChallenges.isEmpty {
                            challengeSection(title: "Active Challenges", challenges: activeChallenges, showProgress: true)
                        }

                        // ═══════════════════════════════════════════════════════
                        // JOIN CHALLENGE BUTTON
                        // ═══════════════════════════════════════════════════════
                        // Opens sheet to browse and join new challenges
                        joinChallengeButton

                        // ═══════════════════════════════════════════════════════
                        // COMPLETED CHALLENGES SECTION
                        // ═══════════════════════════════════════════════════════
                        // Shows past achievements (no progress bars needed)
                        if !completedChallenges.isEmpty {
                            challengeSection(title: "Completed", challenges: completedChallenges, showProgress: false)
                        }

                        // ═══════════════════════════════════════════════════════
                        // EMPTY STATE
                        // ═══════════════════════════════════════════════════════
                        // Shown when user has no challenges at all
                        if challenges.isEmpty {
                            emptyState
                        }
                    } else {
                        // ═══════════════════════════════════════════════════════
                        // PREMIUM REQUIRED PAYWALL
                        // ═══════════════════════════════════════════════════════
                        // Shown to free users - encourages upgrade
                        premiumRequired
                    }
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Challenges")
            .navigationBarTitleDisplayMode(.inline)
            // Done button to close the sheet
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            // Available challenges browser sheet
            .sheet(isPresented: $showingAvailableChallenges) {
                AvailableChallengesSheet { challenge in
                    joinChallenge(challenge)
                }
            }
            // Premium upgrade sheet
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
        }
    }

    // MARK: - Premium Required Paywall

    /// The paywall view shown to free users explaining challenges benefits.
    /// Includes feature list and upgrade button.
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

    /// Quick overview stats shown at the top of the challenges view.
    /// Shows: Active challenges count, Completed count, Total points earned
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

    /// Creates a section with a title and list of challenge cards.
    /// - Parameters:
    ///   - title: Section header text (e.g., "Active Challenges", "Completed")
    ///   - challenges: The challenges to display in this section
    ///   - showProgress: Whether to show progress bars (true for active, false for completed)
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

    /// The main CTA button to browse and join new challenges.
    /// Opens the AvailableChallengesSheet when tapped.
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
            .background(Color.accentSkyBlue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Empty State

    /// Shown when user has no challenges (neither active nor completed).
    /// Encourages user to join their first challenge.
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

    /// Joins a challenge by creating a copy with the current date as start date.
    ///
    /// When a user joins a challenge, we create a new Challenge object based on
    /// the template. The start date is set to now, and it's inserted into SwiftData.
    ///
    /// - Parameter template: The challenge template to join (from available challenges)
    private func joinChallenge(_ template: Challenge) {
        let newChallenge = Challenge(
            title: template.title,
            description: template.challengeDescription,
            type: template.type,
            goal: template.goal,
            startDate: Date(),            // Start now!
            endDate: template.endDate,
            isGlobal: template.isGlobal
        )
        // Save to SwiftData
        modelContext.insert(newChallenge)
        // Celebrate with haptic feedback
        HapticManager.shared.success()
    }

    /// Calculates total points earned from completed challenges.
    /// Currently uses a simple formula: 100 points per completed challenge.
    private func calculateTotalPoints() -> Int {
        completedChallenges.count * 100
    }
}

// =============================================================================
// MARK: - ChallengeCard
// =============================================================================
/// A card displaying a single challenge with its details and progress.
///
/// ## Display Elements
/// - Challenge icon and title
/// - Status text (days remaining, completed, expired)
/// - Global indicator (if applicable) with participant count
/// - Description text
/// - Progress bar (for active challenges)
/// - Completion badge (for completed challenges)

struct ChallengeCard: View {

    /// The challenge data to display
    let challenge: Challenge

    /// Whether to show the progress bar (false for completed challenges)
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundStyle(challenge.isCompleted ? .yellow : .accentSkyBlue)

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
                            .foregroundStyle(Color.accentSkyBlue)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentSkyBlue)
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

    /// Returns the appropriate color for the challenge status text.
    /// - Yellow for completed (success!)
    /// - Red for expired (failed)
    /// - Orange for urgent (2 days or less remaining)
    /// - Secondary for normal active challenges
    private var statusColor: Color {
        if challenge.isCompleted {
            return .yellow      // Success - gold/yellow for achievement
        } else if challenge.isExpired {
            return .red         // Failed - red for missed deadline
        } else if challenge.daysRemaining <= 2 {
            return .orange      // Urgent - orange for time pressure
        } else {
            return .secondary   // Normal - neutral color
        }
    }
}

// =============================================================================
// MARK: - ChallengeStatBox
// =============================================================================
/// A small stat box used in the header stats row.
/// Shows an icon, value, and label in a compact card format.

struct ChallengeStatBox: View {

    /// The numeric value to display (e.g., "3")
    let value: String

    /// The label below the value (e.g., "Active")
    let label: String

    /// The SF Symbol icon name (e.g., "flame.fill")
    let icon: String

    /// The accent color for the icon
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

// =============================================================================
// MARK: - AvailableChallengesSheet
// =============================================================================
/// A sheet displaying available challenges that the user can join.
///
/// Shows a list of predefined challenge templates. When the user taps "Join",
/// the challenge is copied and added to their active challenges.

struct AvailableChallengesSheet: View {

    /// Environment dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss

    /// Callback when user joins a challenge - receives the challenge template
    let onJoin: (Challenge) -> Void

    /// The list of available challenge templates
    /// These are defined in the Challenge model
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

// =============================================================================
// MARK: - AvailableChallengeRow
// =============================================================================
/// A single row in the available challenges list.
///
/// Displays challenge details:
/// - Icon and title
/// - Type badge (e.g., "Global")
/// - Description
/// - Goal and duration
/// - Join button

struct AvailableChallengeRow: View {

    /// The challenge template to display
    let challenge: Challenge

    /// Callback when user taps the join button
    let onJoin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: challenge.type.icon)
                    .font(.title2)
                    .foregroundStyle(Color.accentSkyBlue)

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
                    .background(Color.accentSkyBlue)
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
