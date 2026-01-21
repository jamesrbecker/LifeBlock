import SwiftUI
import SwiftData

// MARK: - Add Friend View

struct AddFriendView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var friendCode = ""
    @State private var makeAccountabilityPartner = false
    @State private var isSearching = false
    @State private var foundUser: UserProfile?
    @State private var errorMessage: String?
    @State private var requestSent = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)

                    Text("Add a Friend")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Enter their friend code to connect and start building together.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.secondaryText)
                        .padding(.horizontal)
                }
                .padding(.top)

                // Friend Code Input
                VStack(spacing: 16) {
                    TextField("Enter Friend Code", text: $friendCode)
                        .textInputAutocapitalization(.characters)
                        .font(.title3)
                        .fontDesign(.monospaced)
                        .foregroundStyle(Color.inputText)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.cardBackgroundLight)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onChange(of: friendCode) { _, newValue in
                            friendCode = String(newValue.uppercased().prefix(6))
                            errorMessage = nil
                            foundUser = nil
                        }

                    Toggle(isOn: $makeAccountabilityPartner) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Accountability Partner")
                                .font(.headline)

                            Text("Get notified if either of you miss a day")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                    .tint(.green)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)

                // Search Button / Results
                if let user = foundUser {
                    FoundUserCard(user: user, isPartner: makeAccountabilityPartner)

                    Button {
                        sendFriendRequest(to: user)
                    } label: {
                        if requestSent {
                            Label("Request Sent!", systemImage: "checkmark.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Send Friend Request")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(requestSent)
                    .padding(.horizontal)
                } else {
                    Button {
                        searchForFriend()
                    } label: {
                        if isSearching {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("Find Friend")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(friendCode.count == 6 ? Color.green : Color.gray)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .disabled(friendCode.count != 6 || isSearching)
                    .padding(.horizontal)
                }

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // Tip
                VStack(spacing: 8) {
                    Text("Building Together")
                        .font(.caption)
                        .fontWeight(.medium)

                    Text("Life is about stacking blocks - each habit, each day, each goal builds on the last. Friends help you stack higher.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func searchForFriend() {
        isSearching = true
        errorMessage = nil

        // Simulate network search - in production this would query CloudKit
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isSearching = false

            // For demo purposes, create a mock user if code looks valid
            if friendCode.count == 6 && friendCode != AppSettings.shared.friendCode {
                foundUser = UserProfile(
                    userID: "user_\(friendCode)",
                    displayName: "Friend \(friendCode.prefix(2))",
                    avatarEmoji: ["😀", "🙂", "😎", "🤓", "💪", "🚀"].randomElement()!,
                    currentStreak: Int.random(in: 1...30),
                    longestStreak: Int.random(in: 5...100),
                    weeklyScore: Int.random(in: 10...28),
                    totalCheckIns: Int.random(in: 20...500),
                    lastActiveDate: Date()
                )
            } else if friendCode == AppSettings.shared.friendCode {
                errorMessage = "That's your own friend code!"
            } else {
                errorMessage = "No user found with that code"
            }
        }
    }

    private func sendFriendRequest(to user: UserProfile) {
        // In production, this would create a FriendRequest and sync to CloudKit
        // For now, directly create the friend connection (demo mode)
        let friend = Friend(
            userID: user.userID,
            displayName: user.displayName,
            avatarEmoji: user.avatarEmoji,
            isAccountabilityPartner: makeAccountabilityPartner
        )
        friend.status = .connected
        friend.currentStreak = user.currentStreak
        friend.longestStreak = user.longestStreak
        friend.weeklyScore = user.weeklyScore
        friend.totalCheckIns = user.totalCheckIns
        friend.lastActivityDate = user.lastActiveDate

        modelContext.insert(friend)
        try? modelContext.save()

        requestSent = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}

// MARK: - Found User Card

struct FoundUserCard: View {
    let user: UserProfile
    let isPartner: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(user.avatarEmoji)
                .font(.system(size: 50))

            VStack(alignment: .leading, spacing: 8) {
                Text(user.displayName)
                    .font(.headline)

                HStack(spacing: 16) {
                    VStack(alignment: .leading) {
                        Text("\(user.currentStreak)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Day Streak")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                    }

                    VStack(alignment: .leading) {
                        Text("\(user.totalCheckIns)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Check-ins")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                if isPartner {
                    Label("Will be your Accountability Partner", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    AddFriendView()
        .modelContainer(for: [Friend.self, FriendRequest.self], inMemory: true)
        .preferredColorScheme(.dark)
}
