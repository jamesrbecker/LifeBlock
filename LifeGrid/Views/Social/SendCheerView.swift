import SwiftUI
import SwiftData

// MARK: - Send Cheer View

struct SendCheerView: View {
    let friend: Friend
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedCheer: Cheer.CheerMessage?
    @State private var sent = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 8) {
                Text("Send a Cheer")
                    .font(.headline)

                Text("to \(friend.displayName)")
                    .foregroundStyle(.secondary)
            }
            .padding(.top)

            // Cheer Options
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                ForEach(Cheer.CheerMessage.allCases, id: \.self) { cheer in
                    Button {
                        selectedCheer = cheer
                    } label: {
                        VStack(spacing: 4) {
                            Text(cheer.rawValue)
                                .font(.system(size: 36))

                            Text(cheer.displayText)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedCheer == cheer ? Color.green.opacity(0.2) : Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            if selectedCheer == cheer {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.green, lineWidth: 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)

            // Send Button
            Button {
                sendCheer()
            } label: {
                if sent {
                    Label("Sent!", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Text("Send Cheer")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedCheer != nil ? Color.green : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(selectedCheer == nil || sent)
            .padding(.horizontal)

            Spacer()
        }
    }

    private func sendCheer() {
        guard let cheer = selectedCheer else { return }

        let settings = AppSettings.shared
        let newCheer = Cheer(
            fromUserID: settings.userID,
            fromDisplayName: settings.displayName,
            toUserID: friend.userID,
            message: cheer
        )

        modelContext.insert(newCheer)
        try? modelContext.save()

        sent = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    let friend = Friend(
        userID: "test123",
        displayName: "Test Friend",
        avatarEmoji: "😀"
    )

    return SendCheerView(friend: friend)
        .modelContainer(for: [Cheer.self], inMemory: true)
        .preferredColorScheme(.dark)
}
