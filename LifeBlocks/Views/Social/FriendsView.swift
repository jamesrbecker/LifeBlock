import SwiftUI
import SwiftData

// MARK: - Friends View (Premium Feature)
/// Main view for friends and accountability partners
/// Privacy-first: Your path, goals, and habits are never shared

struct FriendsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Friend.displayName) private var friends: [Friend]
    @Query private var allRequests: [FriendRequest]

    private var pendingRequests: [FriendRequest] {
        allRequests.filter { $0.status == .pending }
    }

    @StateObject private var purchases = PurchaseManager.shared
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var showingAddFriend = false
    @State private var showingPremium = false
    @State private var showingPrivacySettings = false
    @State private var selectedFriend: Friend?

    var accountabilityPartners: [Friend] {
        friends.filter { $0.isAccountabilityPartner && $0.status == .connected }
    }

    var connectedFriends: [Friend] {
        friends.filter { !$0.isAccountabilityPartner && $0.status == .connected }
    }

    var body: some View {
        NavigationStack {
            Group {
                if purchases.isPremium {
                    friendsContent
                } else {
                    premiumPrompt
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                if purchases.isPremium {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            showingPrivacySettings = true
                        } label: {
                            Image(systemName: appSettings.isPrivateMode ? "lock.shield.fill" : "lock.shield")
                                .foregroundStyle(appSettings.isPrivateMode ? .green : Color.secondaryText)
                        }
                    }
                }
                if purchases.isPremium && !friends.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingAddFriend = true
                        } label: {
                            Image(systemName: "person.badge.plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddFriend) {
                AddFriendView()
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
            .sheet(isPresented: $showingPrivacySettings) {
                NavigationStack {
                    PrivacySettingsView()
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    showingPrivacySettings = false
                                }
                            }
                        }
                }
            }
            .sheet(item: $selectedFriend) { friend in
                FriendDetailView(friend: friend)
            }
        }
    }

    private var friendsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Your Profile Card
                YourProfileCard()

                // Pending Requests
                if !pendingRequests.isEmpty {
                    PendingRequestsSection(requests: pendingRequests)
                }

                // Accountability Partners
                if !accountabilityPartners.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Accountability Partners", systemImage: "person.2.fill")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(accountabilityPartners) { partner in
                            FriendCard(friend: partner, isPartner: true)
                                .onTapGesture {
                                    selectedFriend = partner
                                }
                        }
                    }
                }

                // Friends
                if !connectedFriends.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Friends", systemImage: "person.3.fill")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(connectedFriends) { friend in
                            FriendCard(friend: friend, isPartner: false)
                                .onTapGesture {
                                    selectedFriend = friend
                                }
                        }
                    }
                }

                // Empty State
                if friends.isEmpty && pendingRequests.isEmpty {
                    EmptyFriendsView(showAddFriend: $showingAddFriend)
                }
            }
            .padding(.vertical)
        }
    }

    private var premiumPrompt: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Friends & Accountability")
                .font(.title2)
                .fontWeight(.bold)

            Text("Stay accountable with friends while keeping your journey private. You control exactly what you share.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondaryText)
                .padding(.horizontal, 32)

            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(icon: "lock.shield.fill", text: "Privacy-first: control what friends see")
                FeatureRow(icon: "person.badge.plus", text: "Add friends with a simple code")
                FeatureRow(icon: "hand.thumbsup.fill", text: "Send cheers and encouragement")
                FeatureRow(icon: "eye.slash.fill", text: "Your path & goals stay private")
            }
            .padding(.horizontal, 32)

            Button {
                showingPremium = true
            } label: {
                Text("Upgrade to Premium")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
}

// MARK: - Your Profile Card

struct YourProfileCard: View {
    @ObservedObject var settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 12) {
            // Privacy Status Banner
            if settings.isPrivateMode {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.green)
                    Text("Private Mode Active")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text("Friends see minimal info")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(8)
                .background(Color.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                Text(settings.isPrivateMode ? "🔒" : settings.avatarEmoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(settings.publicDisplayName)
                        .font(.headline)

                    // Only show stats that are being shared
                    HStack(spacing: 12) {
                        if settings.shareStreak && !settings.isPrivateMode {
                            Label("\(settings.currentStreak)", systemImage: "flame.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }

                        if settings.shareWeeklyScore && !settings.isPrivateMode {
                            Label("\(settings.weeklyScore)", systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundStyle(.green)
                        }

                        if settings.isPrivateMode || (!settings.shareStreak && !settings.shareWeeklyScore) {
                            Text("Stats hidden")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                }

                Spacer()

                NavigationLink {
                    EditProfileView()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Friend Code")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)

                    Text(settings.friendCode)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontDesign(.monospaced)
                }

                Spacer()

                Button {
                    UIPasteboard.general.string = settings.friendCode
                    HapticManager.shared.success()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.bordered)

                ShareLink(item: "Add me on LifeBlocks! My friend code is: \(settings.friendCode)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }

            // Privacy hint
            HStack {
                Image(systemName: "info.circle")
                    .font(.caption2)
                Text("Your path, goals, and habits are never shared")
                    .font(.caption2)
            }
            .foregroundStyle(Color.secondaryText)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Friend Card

struct FriendCard: View {
    let friend: Friend
    let isPartner: Bool

    @State private var showingCheerSheet = false

    var body: some View {
        HStack(spacing: 12) {
            Text(friend.avatarEmoji)
                .font(.system(size: 36))

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(friend.displayName)
                        .font(.headline)

                    if isPartner {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }

                HStack(spacing: 12) {
                    Label("\(friend.currentStreak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)

                    Label("\(friend.weeklyScore)/wk", systemImage: "chart.bar.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }

                if let lastActive = friend.lastActivityDate {
                    Text("Active \(lastActive, style: .relative) ago")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Spacer()

            Button {
                showingCheerSheet = true
            } label: {
                Image(systemName: "hand.thumbsup.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .sheet(isPresented: $showingCheerSheet) {
            SendCheerView(friend: friend)
                .presentationDetents([.height(300)])
        }
    }
}

// MARK: - Pending Requests Section

struct PendingRequestsSection: View {
    let requests: [FriendRequest]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Friend Requests", systemImage: "bell.badge.fill")
                .font(.headline)
                .foregroundStyle(.orange)
                .padding(.horizontal)

            ForEach(requests, id: \.id) { request in
                FriendRequestCard(request: request)
            }
        }
    }
}

struct FriendRequestCard: View {
    let request: FriendRequest
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack(spacing: 12) {
            Text(request.fromAvatarEmoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: 4) {
                Text(request.fromDisplayName)
                    .font(.headline)

                if request.includesAccountabilityPartner {
                    Text("Wants to be your accountability partner")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Wants to connect")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                Button {
                    declineRequest()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                }

                Button {
                    acceptRequest()
                } label: {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.green)
                        .padding(8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }

    private func acceptRequest() {
        request.status = .accepted

        // Create friend from request
        let friend = Friend(
            userID: request.fromUserID,
            displayName: request.fromDisplayName,
            avatarEmoji: request.fromAvatarEmoji,
            isAccountabilityPartner: request.includesAccountabilityPartner
        )
        friend.status = .connected
        modelContext.insert(friend)

        try? modelContext.save()
    }

    private func declineRequest() {
        request.status = .declined
        try? modelContext.save()
    }
}

// MARK: - Empty Friends View

struct EmptyFriendsView: View {
    @Binding var showAddFriend: Bool

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2")
                .font(.system(size: 50))
                .foregroundStyle(Color.secondaryText)

            Text("No Friends Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Add friends for accountability while keeping your journey private. You choose what to share.")
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.secondaryText)
                .padding(.horizontal, 32)

            // Privacy assurance
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.green)
                    Text("Your path & goals are always private")
                        .font(.caption)
                }
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.green)
                    Text("Your habits are never shared")
                        .font(.caption)
                }
                HStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.green)
                    Text("You control what friends can see")
                        .font(.caption)
                }
            }
            .foregroundStyle(Color.secondaryText)
            .padding()
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Button {
                showAddFriend = true
            } label: {
                Label("Add Friend", systemImage: "person.badge.plus")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.green)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Preview

#Preview {
    FriendsView()
        .modelContainer(for: [Friend.self, FriendRequest.self], inMemory: true)
        .preferredColorScheme(.dark)
}
