import SwiftUI
import SwiftData

// MARK: - Friend Detail View

struct FriendDetailView: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showingCheerSheet = false
    @State private var showingRemoveAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 12) {
                        Text(friend.avatarEmoji)
                            .font(.system(size: 80))

                        Text(friend.displayName)
                            .font(.title)
                            .fontWeight(.bold)

                        if friend.isAccountabilityPartner {
                            Label("Accountability Partner", systemImage: "checkmark.seal.fill")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                        }

                        Text("Friends since \(friend.connectionDate, style: .date)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top)

                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        FriendStatCard(
                            title: "Current Streak",
                            value: "\(friend.currentStreak)",
                            icon: "flame.fill",
                            color: .orange
                        )

                        FriendStatCard(
                            title: "Longest Streak",
                            value: "\(friend.longestStreak)",
                            icon: "trophy.fill",
                            color: .yellow
                        )

                        FriendStatCard(
                            title: "This Week",
                            value: "\(friend.weeklyScore)",
                            icon: "chart.bar.fill",
                            color: .green
                        )

                        FriendStatCard(
                            title: "Total Check-ins",
                            value: "\(friend.totalCheckIns)",
                            icon: "checkmark.circle.fill",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)

                    // Activity Comparison
                    ComparisonCard(friend: friend)
                        .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            showingCheerSheet = true
                        } label: {
                            Label("Send a Cheer", systemImage: "hand.thumbsup.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        if !friend.isAccountabilityPartner {
                            Button {
                                makeAccountabilityPartner()
                            } label: {
                                Label("Make Accountability Partner", systemImage: "person.2.fill")
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .foregroundStyle(.primary)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }

                        Button {
                            showingRemoveAlert = true
                        } label: {
                            Text("Remove Friend")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingCheerSheet) {
                SendCheerView(friend: friend)
                    .presentationDetents([.height(300)])
            }
            .alert("Remove Friend", isPresented: $showingRemoveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    removeFriend()
                }
            } message: {
                Text("Are you sure you want to remove \(friend.displayName) as a friend? This cannot be undone.")
            }
        }
    }

    private func makeAccountabilityPartner() {
        friend.isAccountabilityPartner = true
        try? modelContext.save()
    }

    private func removeFriend() {
        modelContext.delete(friend)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Friend Stat Card

struct FriendStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Comparison Card

struct ComparisonCard: View {
    let friend: Friend
    let settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How You Compare")
                .font(.headline)

            HStack(spacing: 20) {
                // You
                VStack(spacing: 8) {
                    Text(settings.avatarEmoji)
                        .font(.title)
                    Text("You")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 12) {
                    ComparisonRow(
                        label: "Streak",
                        yourValue: settings.currentStreak,
                        theirValue: friend.currentStreak
                    )

                    ComparisonRow(
                        label: "This Week",
                        yourValue: settings.weeklyScore,
                        theirValue: friend.weeklyScore
                    )

                    ComparisonRow(
                        label: "Total",
                        yourValue: settings.totalCheckIns,
                        theirValue: friend.totalCheckIns
                    )
                }

                // Friend
                VStack(spacing: 8) {
                    Text(friend.avatarEmoji)
                        .font(.title)
                    Text(friend.displayName.prefix(6) + (friend.displayName.count > 6 ? "..." : ""))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ComparisonRow: View {
    let label: String
    let yourValue: Int
    let theirValue: Int

    var winning: Int {
        if yourValue > theirValue { return -1 }
        else if theirValue > yourValue { return 1 }
        return 0
    }

    var body: some View {
        HStack {
            Text("\(yourValue)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(winning == -1 ? .green : .primary)
                .frame(width: 40, alignment: .trailing)

            if winning == -1 {
                Image(systemName: "chevron.left")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else {
                Color.clear.frame(width: 10)
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            if winning == 1 {
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundStyle(.green)
            } else {
                Color.clear.frame(width: 10)
            }

            Text("\(theirValue)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(winning == 1 ? .green : .primary)
                .frame(width: 40, alignment: .leading)
        }
    }
}

// MARK: - Preview

#Preview {
    let friend = Friend(
        userID: "test123",
        displayName: "Sarah M",
        avatarEmoji: "🌟",
        isAccountabilityPartner: true
    )
    friend.currentStreak = 15
    friend.longestStreak = 42
    friend.weeklyScore = 24
    friend.totalCheckIns = 156

    return FriendDetailView(friend: friend)
        .modelContainer(for: [Friend.self, Cheer.self], inMemory: true)
        .preferredColorScheme(.dark)
}
