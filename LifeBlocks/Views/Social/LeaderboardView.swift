import SwiftUI

struct LeaderboardView: View {
    @StateObject private var service = LeaderboardService.shared
    @State private var selectedType: LeaderboardType = .streak
    @State private var selectedScope: LeaderboardScope = .global
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type Picker
                Picker("Leaderboard Type", selection: $selectedType) {
                    ForEach(LeaderboardType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                // Scope Toggle
                Picker("Scope", selection: $selectedScope) {
                    ForEach(LeaderboardScope.allCases, id: \.self) { scope in
                        Label(scope.rawValue, systemImage: scope.icon)
                            .tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                if service.isLoading {
                    Spacer()
                    ProgressView("Loading leaderboard...")
                    Spacer()
                } else if let error = service.error {
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
                    Spacer()
                    EmptyLeaderboardView(scope: selectedScope, showSettings: $showingSettings)
                    Spacer()
                } else {
                    // Leaderboard List
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRowView(
                                    entry: entry,
                                    rank: index + 1,
                                    type: selectedType,
                                    isCurrentUser: entry.userID == AppSettings.shared.userID
                                )
                            }

                            // Show current user if not in top 100
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                LeaderboardSettingsView()
            }
            .onChange(of: selectedType) { _, _ in
                Task {
                    await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
                }
            }
            .onChange(of: selectedScope) { _, _ in
                Task {
                    await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
                }
            }
            .task {
                await service.fetchLeaderboard(type: selectedType, scope: selectedScope)
            }
        }
    }

    private var entries: [LeaderboardEntry] {
        switch selectedScope {
        case .global:
            return service.globalEntries
        case .friends:
            return service.friendEntries
        }
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let rank: Int
    let type: LeaderboardType
    let isCurrentUser: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            ZStack {
                if rank <= 3 {
                    Image(systemName: medalIcon)
                        .font(.title2)
                        .foregroundStyle(medalColor)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                        .frame(width: 30)
                }
            }
            .frame(width: 36)

            // Avatar
            Text(entry.avatarEmoji)
                .font(.title)

            // Name and stats
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(entry.displayName)
                        .font(.headline)
                        .lineLimit(1)

                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                Text("\(Int(entry.consistencyPercent))% consistency")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()

            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text(scoreText)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(isCurrentUser ? .blue : .primary)

                Text(scoreLabel)
                    .font(.caption2)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentUser ? Color.blue.opacity(0.1) : Color(.systemGray6))
        )
    }

    private var medalIcon: String {
        switch rank {
        case 1: return "medal.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "circle"
        }
    }

    private var medalColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .orange
        default: return .secondary
        }
    }

    private var scoreText: String {
        switch type {
        case .streak:
            return "\(entry.currentStreak)"
        case .weekly:
            return "\(entry.weeklyScore)"
        case .monthly:
            return "\(entry.monthlyScore)"
        case .allTime:
            return "\(entry.lifetimeScore)"
        }
    }

    private var scoreLabel: String {
        switch type {
        case .streak:
            return entry.currentStreak == 1 ? "day" : "days"
        case .weekly:
            return "this week"
        case .monthly:
            return "this month"
        case .allTime:
            return "total"
        }
    }
}

// MARK: - Empty State

struct EmptyLeaderboardView: View {
    let scope: LeaderboardScope
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: scope == .global ? "globe" : "person.2")
                .font(.system(size: 48))
                .foregroundStyle(Color.secondaryText)

            Text(scope == .global ? "Join the Global Leaderboard" : "No Friends Yet")
                .font(.headline)

            Text(scope == .global ?
                 "Opt in to compete with users worldwide and see how your consistency stacks up." :
                 "Add friends to see how you compare and keep each other accountable.")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

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

// MARK: - Settings Sheet

struct LeaderboardSettingsView: View {
    @StateObject private var service = LeaderboardService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String = AppSettings.shared.displayName
    @State private var selectedEmoji: String = AppSettings.shared.avatarEmoji

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
                        .foregroundStyle(.green)

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

    private func saveSettings() {
        AppSettings.shared.displayName = displayName
        AppSettings.shared.avatarEmoji = selectedEmoji

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
