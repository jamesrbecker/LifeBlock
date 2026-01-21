import SwiftUI

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var displayName: String
    @State private var selectedEmoji: String

    let emojiOptions = [
        "😀", "😃", "😄", "😁", "😎", "🤓", "🧐", "😊",
        "🙂", "😌", "🤩", "🥳", "😏", "😺", "🦊", "🐻",
        "🦁", "🐯", "🦄", "🐉", "🔥", "⭐️", "🌟", "💫",
        "🚀", "💪", "🏆", "🎯", "💡", "🧠", "❤️", "💚"
    ]

    init() {
        let settings = AppSettings.shared
        _displayName = State(initialValue: settings.displayName)
        _selectedEmoji = State(initialValue: settings.avatarEmoji)
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 16) {
                    Text(selectedEmoji)
                        .font(.system(size: 80))

                    Text("Tap an emoji below to change")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
            }

            Section("Choose Your Avatar") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.title)
                                .padding(6)
                                .background(selectedEmoji == emoji ? Color.accentGreen.opacity(0.3) : Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay {
                                    if selectedEmoji == emoji {
                                        RoundedRectangle(cornerRadius: 8)
                                            .strokeBorder(Color.accentGreen, lineWidth: 2)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
            }

            Section("Display Name") {
                TextField("Your Name", text: $displayName)
                    .foregroundStyle(Color.inputText)
                    .textInputAutocapitalization(.words)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Your Friend Code")
                        Spacer()
                        Text(AppSettings.shared.friendCode)
                            .fontDesign(.monospaced)
                            .fontWeight(.bold)
                    }

                    Text("Share this code with friends so they can add you")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Building Blocks Philosophy", systemImage: "cube.fill")
                        .font(.headline)
                        .foregroundStyle(Color.accentGreen)

                    Text("Life is about stacking skills, learning, and building blocks toward your goals. Each day you check in, you stack another block. Each habit you complete adds to your foundation.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)

                    Text("Your avatar represents you on this journey. Choose one that inspires you to keep building.")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveProfile()
                }
            }
        }
    }

    private func saveProfile() {
        let settings = AppSettings.shared
        settings.displayName = displayName.isEmpty ? "User" : displayName
        settings.avatarEmoji = selectedEmoji
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        EditProfileView()
    }
    .preferredColorScheme(.dark)
}
