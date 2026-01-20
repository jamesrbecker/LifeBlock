import SwiftUI
import SwiftData

enum HabitEditorMode {
    case create
    case edit(Habit)

    var title: String {
        switch self {
        case .create: return "New Habit"
        case .edit: return "Edit Habit"
        }
    }

    var habit: Habit? {
        switch self {
        case .create: return nil
        case .edit(let habit): return habit
        }
    }
}

struct HabitEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let mode: HabitEditorMode

    @State private var name: String = ""
    @State private var selectedIcon: String = "checkmark.circle.fill"
    @State private var selectedColor: String = "#30A14E"

    private let iconOptions = [
        "checkmark.circle.fill",
        "figure.run",
        "bed.double.fill",
        "book.fill",
        "briefcase.fill",
        "heart.fill",
        "brain.head.profile",
        "cup.and.saucer.fill",
        "fork.knife",
        "drop.fill",
        "leaf.fill",
        "sun.max.fill",
        "moon.fill",
        "music.note",
        "paintpalette.fill",
        "pencil",
        "phone.fill",
        "house.fill",
        "car.fill",
        "bicycle",
        "figure.walk",
        "figure.yoga",
        "dumbbell.fill",
        "pills.fill",
        "cross.case.fill",
        "banknote.fill",
        "creditcard.fill",
        "cart.fill",
        "gift.fill",
        "gamecontroller.fill"
    ]

    private let colorOptions = [
        "#30A14E", // Green
        "#0550AE", // Blue
        "#8B5CF6", // Purple
        "#EA580C", // Orange
        "#DB2777", // Pink
        "#DC2626", // Red
        "#059669", // Teal
        "#7C3AED", // Violet
        "#F59E0B"  // Amber
    ]

    init(mode: HabitEditorMode) {
        self.mode = mode

        if let habit = mode.habit {
            _name = State(initialValue: habit.name)
            _selectedIcon = State(initialValue: habit.icon)
            _selectedColor = State(initialValue: habit.colorHex)
        }
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                // Preview section
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: selectedIcon)
                                .font(.system(size: 48))
                                .foregroundStyle(Color(hex: selectedColor))

                            Text(name.isEmpty ? "Habit Name" : name)
                                .font(.headline)
                                .foregroundStyle(name.isEmpty ? .secondary : .primary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                }

                // Name input
                Section("Name") {
                    TextField("Enter habit name", text: $name)
                        .textInputAutocapitalization(.words)
                }

                // Icon picker
                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : .secondary)
                                    .frame(width: 44, height: 44)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(selectedIcon == icon ? Color(hex: selectedColor).opacity(0.2) : Color.clear)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(selectedIcon == icon ? Color(hex: selectedColor) : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Color picker
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
                        ForEach(colorOptions, id: \.self) { color in
                            Button {
                                selectedColor = color
                            } label: {
                                Circle()
                                    .fill(Color(hex: color))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        if selectedColor == color {
                                            Image(systemName: "checkmark")
                                                .font(.headline)
                                                .fontWeight(.bold)
                                                .foregroundStyle(.white)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .create:
            let habit = Habit(
                name: trimmedName,
                icon: selectedIcon,
                colorHex: selectedColor,
                isSystemHabit: false
            )
            modelContext.insert(habit)

        case .edit(let habit):
            habit.name = trimmedName
            habit.icon = selectedIcon
            habit.colorHex = selectedColor
        }

        try? modelContext.save()
        dismiss()
    }
}

#Preview("Create") {
    HabitEditorView(mode: .create)
        .modelContainer(for: Habit.self, inMemory: true)
        .preferredColorScheme(.dark)
}
