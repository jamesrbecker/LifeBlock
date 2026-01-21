import SwiftUI

// MARK: - Daily Note View
/// Premium feature: Add a quick journal note and mood after check-in

struct DailyNoteView: View {
    @Binding var note: String
    @Binding var mood: Int?
    @Binding var isPresented: Bool
    let onSave: () -> Void

    @State private var selectedMood: Int? = nil
    @FocusState private var isNoteFocused: Bool

    private let moodEmojis = ["😫", "😕", "😐", "🙂", "😊"]
    private let moodLabels = ["Rough", "Meh", "Okay", "Good", "Great"]

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("How was your day?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Quick reflection (optional)")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.top)

                // Mood selector
                VStack(spacing: 12) {
                    Text("Mood")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        ForEach(0..<5, id: \.self) { index in
                            MoodButton(
                                emoji: moodEmojis[index],
                                label: moodLabels[index],
                                isSelected: selectedMood == index + 1,
                                action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedMood = index + 1
                                        mood = index + 1
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal)

                // Note input
                VStack(spacing: 12) {
                    Text("Quick Note")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ZStack(alignment: .topLeading) {
                        if note.isEmpty {
                            Text("What happened today? What are you grateful for?")
                                .foregroundStyle(Color.placeholderText)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                        }

                        TextEditor(text: $note)
                            .focused($isNoteFocused)
                            .foregroundStyle(Color.inputText)
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .padding(4)
                    }
                    .background(Color.cardBackgroundLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.borderColor, lineWidth: 1)
                    )

                    Text("\(note.count)/280")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)

                Spacer()

                // Save button
                Button(action: {
                    onSave()
                    isPresented = false
                }) {
                    Text("Save & Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal)

                // Skip button
                Button(action: {
                    isPresented = false
                }) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.bottom)
            }
            .background(Color.gridBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isNoteFocused = false
                    }
                    .opacity(isNoteFocused ? 1 : 0)
                }
            }
        }
    }
}

// MARK: - Mood Button

struct MoodButton: View {
    let emoji: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 32))

                Text(label)
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .primary : Color.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.green.opacity(0.2) : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mood Display (for viewing past entries)

struct MoodDisplay: View {
    let mood: Int

    private let moodEmojis = ["😫", "😕", "😐", "🙂", "😊"]

    var body: some View {
        if mood >= 1 && mood <= 5 {
            Text(moodEmojis[mood - 1])
                .font(.title2)
        }
    }
}

// MARK: - Note Preview Card

struct NotePreviewCard: View {
    let note: String
    let mood: Int?
    let date: Date

    private let moodEmojis = ["😫", "😕", "😐", "🙂", "😊"]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Spacer()

                if let mood = mood, mood >= 1 && mood <= 5 {
                    Text(moodEmojis[mood - 1])
                }
            }

            if !note.isEmpty {
                Text(note)
                    .font(.subheadline)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Journal History View (Premium)

struct JournalHistoryView: View {
    let entries: [(date: Date, note: String, mood: Int?)]

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(entries.indices, id: \.self) { index in
                    let entry = entries[index]
                    NotePreviewCard(
                        note: entry.note,
                        mood: entry.mood,
                        date: entry.date
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Journal")
        .background(Color.gridBackground)
    }
}

// MARK: - Preview

#Preview {
    DailyNoteView(
        note: .constant(""),
        mood: .constant(nil),
        isPresented: .constant(true),
        onSave: {}
    )
    .preferredColorScheme(.dark)
}
