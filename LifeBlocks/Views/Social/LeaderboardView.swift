import SwiftUI

// =============================================================================
// MARK: - LeaderboardView.swift
// =============================================================================
/// The main view for displaying leaderboard rankings.
///
/// ## Overview
/// This view displays a competitive leaderboard where users can see how they
/// rank against others in the LifeBlocks community. It supports three different
/// scopes (Global, My Path, Friends) and four different ranking types
/// (Streak, Weekly, Monthly, All Time).
///
/// ## Premium Feature
/// Leaderboards are a premium-only feature. Free users see a paywall with
/// a preview of what they're missing and a button to upgrade.
///
/// ## Scopes
/// - **Global**: See rankings of all opted-in users worldwide
/// - **My Path**: Only see users on the same life path (e.g., Software Engineers)
/// - **Friends**: Only see users you've added as friends
///
/// ## Ranking Types
/// - **Streak**: Ranked by current consecutive day streak
/// - **Weekly**: Ranked by points earned this week
/// - **Monthly**: Ranked by points earned this month
/// - **All Time**: Ranked by total lifetime points
///
/// ## Key Features
/// - Top 3 users get medal badges (gold, silver, bronze)
/// - Current user is highlighted in blue
/// - If current user is outside top 100, they appear at the bottom
/// - Settings sheet for profile customization and privacy opt-in/out
/// - Add friends functionality via friend codes

struct LeaderboardView: View {

    // MARK: - Properties

    /// Reference to the shared LeaderboardService singleton that handles all CloudKit operations
    /// This is the data source for all leaderboard entries
    @StateObject private var service = LeaderboardService.shared

    /// Reference to the subscription status to check if user has premium access
    /// Leaderboards require premium - free users see a paywall
    @ObservedObject private var subscription = SubscriptionStatus.shared

    /// The currently selected ranking type (Streak, Weekly, Monthly, All Time)
    /// Changes which score is used for ranking
    @State private var selectedType: LeaderboardType = .streak

    /// The currently selected scope (Global, My Path, Friends)
    /// Filters which users appear on the leaderboard
    @State private var selectedScope: LeaderboardScope = .global

    /// Controls whether the leaderboard settings sheet is displayed
    /// Settings include profile name, avatar, and privacy opt-in
    @State private var showingSettings = false

    /// Controls whether the premium upgrade sheet is displayed
    /// Shown when free users try to access leaderboards
    @State private var showingPremium = false

    /// Controls whether the add friend sheet is displayed
    /// Allows users to add friends via friend codes
    @State private var showingAddFriend = false

    // MARK: - Computed Properties

    /// Gets the current user's selected life path (if any)
    /// Used to filter the "My Path" leaderboard scope
    /// Returns nil if user is in exploration mode
    private var userPath: LifePathCategory? {
        AppSettings.shared.userLifePath?.selectedPath
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            // Check if user has premium access to leaderboards
            // Premium users see the full leaderboard, free users see an upgrade prompt
            if subscription.canAccessLeaderboards {
                leaderboardContent
            } else {
                premiumRequired
            }
        }
    }

    // MARK: - Leaderboard Content (Premium Users)

    /// The main leaderboard content shown to premium users.
    /// Includes type picker, scope picker, and the list of entries.
    private var leaderboardContent: some View {
        VStack(spacing: 0) {
            // ═══════════════════════════════════════════════════════════════
            // LEADERBOARD TYPE PICKER
            // ═══════════════════════════════════════════════════════════════
            // Allows users to choose which metric to rank by:
            // - Streak: Current consecutive days
            // - Weekly: Points this week
            // - Monthly: Points this month
            // - All Time: Total lifetime points
            Picker("Leaderboard Type", selection: $selectedType) {
                ForEach(LeaderboardType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // ═══════════════════════════════════════════════════════════════
            // LEADERBOARD SCOPE PICKER
            // ═══════════════════════════════════════════════════════════════
            // Allows users to choose which users to see:
            // - Global: All opted-in users worldwide
            // - My Path: Only users on the same life path
            // - Friends: Only added friends
            Picker("Scope", selection: $selectedScope) {
                ForEach(LeaderboardScope.allCases, id: \.self) { scope in
                    // Only show "My Path" option if user has selected a path
                    // Users in exploration mode won't see this option
                    if scope == .path && userPath == nil {
                        EmptyView()
                    } else {
                        // For path scope, show the actual path name (e.g., "Software Engineer")
                        Label(scope == .path ? (userPath?.displayName ?? "My Path") : scope.rawValue, systemImage: scope.icon)
                            .tag(scope)
                    }
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.top, 8)

            // ═══════════════════════════════════════════════════════════════
            // PATH INFO BANNER
            // ═══════════════════════════════════════════════════════════════
            // When viewing the path-specific leaderboard, show a banner
            // explaining that you're competing with others on the same path
            if selectedScope == .path, let path = userPath {
                HStack(spacing: 8) {
                    Image(systemName: path.icon)
                        .foregroundStyle(path.color)
                    Text("Competing with other \(path.displayName)s")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(path.color.opacity(0.1))
            }

            // ═══════════════════════════════════════════════════════════════
            // CONTENT STATES
            // ═══════════════════════════════════════════════════════════════
            // The leaderboard can be in one of four states:
            // 1. Loading - Show a progress indicator
            // 2. Error - Show error message with retry button
            // 3. Empty - Show empty state with instructions
            // 4. Populated - Show the actual leaderboard list

            if service.isLoading {
                // STATE 1: LOADING
                // Show a spinner while fetching data from CloudKit
                Spacer()
                ProgressView("Loading leaderboard...")
                Spacer()
            } else if let error = service.error {
                // STATE 2: ERROR
                // Something went wrong (network error, CloudKit error, etc.)
                // Show the error message and a retry button
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(Color.secondaryText)
                    Text(error)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                Spacer()
            } else if entries.isEmpty {
                // STATE 3: EMPTY
                // No entries to display (user not opted in, no friends, etc.)
                // Show contextual empty state based on current scope
                Spacer()
                EmptyLeaderboardView(scope: selectedScope, showSettings: $showingSettings)
                Spacer()
            } else {
                // STATE 4: POPULATED
                // We have leaderboard entries to display!
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Loop through all entries and display them with their rank
                        // enumerated() gives us both the index and the entry
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRowView(
                                entry: entry,
                                rank: index + 1,           // Ranks are 1-indexed for display
                                type: selectedType,
                                isCurrentUser: entry.userID == AppSettings.shared.userID  // Highlight if this is you
                            )
                        }

                        // ═══════════════════════════════════════════════════════════
                        // CURRENT USER OUTSIDE TOP 100
                        // ═══════════════════════════════════════════════════════════
                        // If the current user isn't in the top 100, show their entry
                        // at the bottom separated by a divider so they can still see
                        // their rank even if they're not competitive yet
                        if let currentEntry = service.currentUserEntry,
                           let rank = service.currentUserRank,
                           rank > 100 {
                            Divider()
                                .padding(.vertical, 8)

                            LeaderboardRowView(
                                entry: currentEntry,
                                rank: rank,
                                type: selectedType,
                                isCurrentUser: true
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Leaderboard")
        // ═══════════════════════════════════════════════════════════════════
        // TOOLBAR BUTTONS
        // ═══════════════════════════════════════════════════════════════════
        .toolbar {
            // LEFT: Add Friend button - opens sheet to add friends via code
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingAddFriend = true
                } label: {
                    Image(systemName: "person.badge.plus")
                }
            }
            // RIGHT: Settings button - opens profile/privacy settings
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        // ═══════════════════════════════════════════════════════════════════
        // SHEET PRESENTATIONS
        // ═══════════════════════════════════════════════════════════════════
        // Settings sheet - customize profile and privacy settings
        .sheet(isPresented: $showingSettings) {
            LeaderboardSettingsView()
        }
        // Add friend sheet - add friends via friend codes
        .sheet(isPresented: $showingAddFriend) {
            AddFriendView()
        }
        // ═══════════════════════════════════════════════════════════════════
        // DATA FETCHING TRIGGERS
        // ═══════════════════════════════════════════════════════════════════
        // When leaderboard type changes (Streak → Weekly, etc.), refetch data
        .onChange(of: selectedType) { _, _ in
            Task {
                await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
            }
        }
        // When scope changes (Global → Friends, etc.), refetch data
        .onChange(of: selectedScope) { _, _ in
            Task {
                await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
            }
        }
        // Initial data fetch when view appears
        .task {
            await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
        }
    }

    // MARK: - Premium Required (Free Users)

    /// The paywall view shown to free users who try to access leaderboards.
    /// Shows the value of leaderboards and encourages upgrade to premium.
    private var premiumRequired: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "trophy.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)

            VStack(spacing: 8) {
                Text("Leaderboards")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("See how you rank against the community and compete with friends.")
                    .font(.body)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                FeatureRow(icon: "globe", text: "Global rankings", color: .blue)
                FeatureRow(icon: "person.2.fill", text: "Friend leaderboards", color: .green)
                FeatureRow(icon: "chart.bar.fill", text: "Weekly & all-time stats", color: .purple)
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
        .navigationTitle("Leaderboard")
        .sheet(isPresented: $showingPremium) {
            PremiumView()
        }
    }

    // MARK: - Computed Properties

    /// Returns the appropriate leaderboard entries based on the currently selected scope.
    /// This is a convenience property that routes to the correct data array in the service.
    private var entries: [LeaderboardEntry] {
        switch selectedScope {
        case .global:
            // All opted-in users worldwide
            return service.globalEntries
        case .path:
            // Only users on the same life path
            return service.pathEntries
        case .friends:
            // Only users added as friends
            return service.friendEntries
        }
    }
}

// =============================================================================
// MARK: - LeaderboardRowView
// =============================================================================
/// A single row in the leaderboard displaying one user's entry.
///
/// ## Display Elements
/// - **Rank**: Position on the leaderboard (1-3 get medals, others get numbers)
/// - **Avatar**: The user's chosen emoji avatar
/// - **Name**: Display name (plus "(You)" indicator if current user)
/// - **Consistency**: Percentage of days with check-ins
/// - **Score**: The relevant score based on leaderboard type
///
/// ## Visual Indicators
/// - Gold medal for 1st place
/// - Silver medal for 2nd place
/// - Bronze medal for 3rd place
/// - Blue highlight for current user's row

struct LeaderboardRowView: View {

    // MARK: - Properties

    /// The leaderboard entry data to display
    let entry: LeaderboardEntry

    /// The user's rank/position on the leaderboard (1-indexed)
    let rank: Int

    /// The current leaderboard type (determines which score to show)
    let type: LeaderboardType

    /// Whether this entry belongs to the current user (triggers blue highlight)
    let isCurrentUser: Bool

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // ═══════════════════════════════════════════════════════════════
            // RANK INDICATOR
            // ═══════════════════════════════════════════════════════════════
            // Top 3 get medal icons, everyone else gets a number
            ZStack {
                if rank <= 3 {
                    // Medal for top 3 (gold, silver, bronze)
                    Image(systemName: medalIcon)
                        .font(.title2)
                        .foregroundStyle(medalColor)
                } else {
                    // Plain number for rank 4+
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                        .frame(width: 30)
                }
            }
            .frame(width: 36)

            // ═══════════════════════════════════════════════════════════════
            // AVATAR EMOJI
            // ═══════════════════════════════════════════════════════════════
            // The user's chosen emoji avatar (customizable in settings)
            Text(entry.avatarEmoji)
                .font(.title)

            // ═══════════════════════════════════════════════════════════════
            // USER INFO (Name + Consistency)
            // ═══════════════════════════════════════════════════════════════
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    // Display name
                    Text(entry.displayName)
                        .font(.headline)
                        .lineLimit(1)

                    // Add "(You)" indicator for current user
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                // Consistency percentage (days with check-ins / total days)
                Text("\(Int(entry.consistencyPercent))% consistency")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()

            // ═══════════════════════════════════════════════════════════════
            // SCORE DISPLAY
            // ═══════════════════════════════════════════════════════════════
            // Shows the relevant score based on leaderboard type
            VStack(alignment: .trailing, spacing: 2) {
                // Main score value (streak count, weekly points, etc.)
                Text(scoreText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isCurrentUser ? .blue : .primary)  // Blue for current user

                // Score label (e.g., "days", "this week", "total")
                Text(scoreLabel)
                    .font(.caption2)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        // Row background - blue tint for current user, gray for others
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
    }

    // MARK: - Medal Helpers

    /// Returns the SF Symbol name for the medal icon
    /// All top 3 use the same icon but different colors
    private var medalIcon: String {
        switch rank {
        case 1: return "medal.fill"   // Gold
        case 2: return "medal.fill"   // Silver
        case 3: return "medal.fill"   // Bronze
        default: return "circle"       // Not used (ranks 4+ show numbers)
        }
    }

    /// Returns the color for the medal based on rank
    /// 1st = Gold, 2nd = Silver, 3rd = Bronze
    private var medalColor: Color {
        switch rank {
        case 1: return .yellow   // Gold medal
        case 2: return .gray     // Silver medal
        case 3: return .orange   // Bronze medal
        default: return .secondary
        }
    }

    // MARK: - Score Helpers

    /// Returns the score value to display based on the current leaderboard type
    /// Each type shows a different metric from the entry
    private var scoreText: String {
        switch type {
        case .streak:
            return "\(entry.currentStreak)"     // Current consecutive days
        case .weekly:
            return "\(entry.weeklyScore)"       // Points earned this week
        case .monthly:
            return "\(entry.monthlyScore)"      // Points earned this month
        case .allTime:
            return "\(entry.lifetimeScore)"     // Total lifetime points
        }
    }

    /// Returns the label text below the score (e.g., "days", "this week")
    /// Provides context for what the number means
    private var scoreLabel: String {
        switch type {
        case .streak:
            return entry.currentStreak == 1 ? "day" : "days"  // Singular/plural
        case .weekly:
            return "this week"
        case .monthly:
            return "this month"
        case .allTime:
            return "total"
        }
    }
}

// =============================================================================
// MARK: - EmptyLeaderboardView
// =============================================================================
/// Displayed when the leaderboard has no entries to show.
///
/// This can happen in several scenarios:
/// - **Global scope**: User hasn't opted into the global leaderboard
/// - **Friends scope**: User hasn't added any friends yet
/// - **Path scope**: No other users on the same path
///
/// The view adapts its message and call-to-action based on the current scope.

struct EmptyLeaderboardView: View {

    /// The current leaderboard scope (determines the empty state message)
    let scope: LeaderboardScope

    /// Binding to control whether the settings sheet should be shown
    /// Used to let users opt into the global leaderboard
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 16) {
            // Icon changes based on scope
            Image(systemName: scope == .global ? "globe" : "person.2")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondaryText)

            // Title - contextual based on scope
            Text(scope == .global ? "Join the Global Leaderboard" : "No Friends Yet")
                .font(.headline)

            // Description - explains why it's empty and what to do
            Text(scope == .global ?
                 "Opt in to compete with users worldwide and see how your consistency stacks up." :
                 "Add friends to see how you compare and keep each other accountable.")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // CTA button for global scope - opens settings to opt in
            if scope == .global {
                Button {
                    showSettings = true
                } label: {
                    Label("Enable Global Leaderboard", systemImage: "globe")
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

// =============================================================================
// MARK: - LeaderboardSettingsView
// =============================================================================
/// The settings sheet for customizing leaderboard profile and privacy.
///
/// ## Profile Settings
/// - **Display Name**: The name shown on the leaderboard (can be different from real name)
/// - **Avatar**: Choose an emoji to represent yourself
///
/// ## Privacy Settings
/// - **Global Opt-In**: Toggle to appear on the global leaderboard
/// - Privacy info showing what IS and ISN'T shared
///
/// ## What's Shared (when opted in)
/// - Display name
/// - Avatar emoji
/// - Streak and scores
/// - Consistency percentage
///
/// ## What's NEVER Shared
/// - Email address
/// - Habit names
/// - Check-in times
/// - Location

struct LeaderboardSettingsView: View {

    // MARK: - Properties

    /// Reference to the LeaderboardService for updating opt-in status
    @StateObject private var service = LeaderboardService.shared

    /// Environment dismiss action to close the sheet
    @Environment(\.dismiss) private var dismiss

    /// The user's display name (editable, saved on dismiss)
    @State private var displayName: String = AppSettings.shared.displayName

    /// The user's selected avatar emoji (editable, saved on dismiss)
    @State private var selectedEmoji: String = AppSettings.shared.avatarEmoji

    /// The available emoji options for avatars
    /// These are fun, expressive emojis that work well as profile pictures
    let emojiOptions = ["😀", "😎", "🔥", "💪", "🚀", "⭐️", "🏃", "🧘", "📚", "🎯", "🏆", "💎", "🌟", "🦁", "🐺", "🦅"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile") {
                    HStack {
                        Text("Display Name")
                        Spacer()
                        TextField("Name", text: $displayName)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 150)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Avatar")
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                            ForEach(emojiOptions, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.title2)
                                    .padding(6)
                                    .background(
                                        Circle()
                                            .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.clear)
                                    )
                                    .onTapGesture {
                                        selectedEmoji = emoji
                                        HapticManager.shared.selection()
                                    }
                            }
                        }
                    }
                }

                Section {
                    Toggle("Show on Global Leaderboard", isOn: Binding(
                        get: { service.isOptedIntoGlobal },
                        set: { newValue in
                            Task {
                                await service.setGlobalOptIn(newValue)
                            }
                        }
                    ))
                } header: {
                    Text("Privacy")
                } footer: {
                    Text("When enabled, your display name, avatar, and stats will be visible to all LifeBlocks users on the global leaderboard.")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("What's Shared", systemImage: "eye")
                            .font(.headline)

                        Group {
                            Label("Display name", systemImage: "checkmark.circle.fill")
                            Label("Avatar emoji", systemImage: "checkmark.circle.fill")
                            Label("Streak & scores", systemImage: "checkmark.circle.fill")
                            Label("Consistency %", systemImage: "checkmark.circle.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color.accentGreen)

                        Divider()
                            .padding(.vertical, 4)

                        Label("Never Shared", systemImage: "eye.slash")
                            .font(.headline)

                        Group {
                            Label("Email address", systemImage: "xmark.circle.fill")
                            Label("Habit names", systemImage: "xmark.circle.fill")
                            Label("Check-in times", systemImage: "xmark.circle.fill")
                            Label("Location", systemImage: "xmark.circle.fill")
                        }
                        .font(.subheadline)
                        .foregroundStyle(.red)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy Info")
                }
            }
            .navigationTitle("Leaderboard Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveSettings()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Save Settings

    /// Saves the profile settings to AppSettings and updates CloudKit if opted in.
    ///
    /// This function:
    /// 1. Saves display name and avatar emoji locally
    /// 2. If user is opted into global leaderboard, pushes update to CloudKit
    private func saveSettings() {
        // Save locally
        AppSettings.shared.displayName = displayName
        AppSettings.shared.avatarEmoji = selectedEmoji

        // If opted in, sync to CloudKit so others see the updated profile
        if service.isOptedIntoGlobal {
            Task {
                await service.updateCurrentUserEntry()
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
