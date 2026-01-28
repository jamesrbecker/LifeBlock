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
    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    private var allHabits: [Habit]

    let mode: HabitEditorMode

    @ObservedObject private var purchases = PurchaseManager.shared

    @State private var name: String = ""
    @State private var selectedIcon: String = "checkmark.circle.fill"
    @State private var selectedColor: String = "#30A14E"
    @State private var stackedAfterHabitId: UUID? = nil
    @State private var showingStackPicker = false
    @State private var selectedDays: Set<Int> = []  // Empty = every day
    @State private var showingPremiumForScheduling = false

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
            _stackedAfterHabitId = State(initialValue: habit.stackedAfterHabitId)
            _selectedDays = State(initialValue: habit.scheduledDayNumbers)
        }
    }

    private var availableHabitsForStacking: [Habit] {
        // Filter out the current habit being edited
        allHabits.filter { habit in
            if case .edit(let editingHabit) = mode {
                return habit.id != editingHabit.id
            }
            return true
        }
    }

    private var stackedAfterHabit: Habit? {
        guard let id = stackedAfterHabitId else { return nil }
        return allHabits.first { $0.id == id }
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
                                .foregroundStyle(name.isEmpty ? Color.secondaryText : .primary)
                        }
                        .padding(.vertical, 20)
                        Spacer()
                    }
                }

                // Name input
                Section("Name") {
                    TextField("Enter habit name", text: $name)
                        .foregroundStyle(Color.inputText)
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
                                    .foregroundStyle(selectedIcon == icon ? Color(hex: selectedColor) : Color.secondaryText)
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

                // Habit Scheduling (Premium)
                Section {
                    if purchases.isPremium {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundStyle(Color.accentSkyBlue)
                                Text("Schedule Days")
                                Spacer()
                                Text(scheduleDisplayText)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }

                            HStack(spacing: 8) {
                                ForEach(dayOptions, id: \.number) { day in
                                    Button {
                                        toggleDay(day.number)
                                    } label: {
                                        Text(day.shortName)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .frame(width: 38, height: 38)
                                            .background(
                                                Circle()
                                                    .fill(isDaySelected(day.number)
                                                          ? Color(hex: selectedColor).opacity(0.3)
                                                          : Color.secondary.opacity(0.15))
                                            )
                                            .overlay(
                                                Circle()
                                                    .strokeBorder(isDaySelected(day.number)
                                                                  ? Color(hex: selectedColor)
                                                                  : Color.clear, lineWidth: 2)
                                            )
                                            .foregroundStyle(isDaySelected(day.number) ? .primary : Color.secondaryText)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button {
                            showingPremiumForScheduling = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "calendar")
                                            .foregroundStyle(Color.accentSkyBlue)
                                        Text("Schedule Specific Days")
                                            .foregroundStyle(.primary)
                                    }
                                    Text("Upgrade to Premium to set which days this habit is active")
                                        .font(.caption)
                                        .foregroundStyle(Color.secondaryText)
                                }
                                Spacer()
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                } header: {
                    Text("Schedule")
                } footer: {
                    Text("Choose which days of the week to track this habit. Leave all selected for every day.")
                }

                // Habit Stacking
                Section {
                    Button {
                        showingStackPicker = true
                    } label: {
                        HStack {
                            Image(systemName: "link")
                                .foregroundStyle(.blue)

                            Text("Stack After")

                            Spacer()

                            if let habit = stackedAfterHabit {
                                HStack(spacing: 6) {
                                    Image(systemName: habit.icon)
                                        .font(.caption)
                                        .foregroundStyle(Color(hex: habit.colorHex))
                                    Text(habit.name)
                                        .foregroundStyle(Color.secondaryText)
                                }
                            } else {
                                Text("None")
                                    .foregroundStyle(Color.secondaryText)
                            }

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                } header: {
                    Text("Habit Stacking")
                } footer: {
                    Text("Link habits together. When you complete one habit, you'll be prompted to do the next one in your stack.")
                }
            }
            .sheet(isPresented: $showingStackPicker) {
                HabitStackPicker(
                    selectedHabitId: $stackedAfterHabitId,
                    availableHabits: availableHabitsForStacking
                )
            }
            .sheet(isPresented: $showingPremiumForScheduling) {
                PremiumView()
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

    // MARK: - Day Scheduling Helpers

    private struct DayOption {
        let number: Int  // 1=Sunday, 7=Saturday
        let shortName: String
    }

    private let dayOptions: [DayOption] = [
        DayOption(number: 1, shortName: "S"),
        DayOption(number: 2, shortName: "M"),
        DayOption(number: 3, shortName: "T"),
        DayOption(number: 4, shortName: "W"),
        DayOption(number: 5, shortName: "T"),
        DayOption(number: 6, shortName: "F"),
        DayOption(number: 7, shortName: "S")
    ]

    private func isDaySelected(_ day: Int) -> Bool {
        selectedDays.isEmpty || selectedDays.contains(day)
    }

    private func toggleDay(_ day: Int) {
        if selectedDays.isEmpty {
            // Currently "every day" — switching to specific days means select all except tapped
            selectedDays = Set(1...7)
            selectedDays.remove(day)
        } else if selectedDays.contains(day) {
            selectedDays.remove(day)
            // Don't allow zero days selected — revert to every day
            if selectedDays.isEmpty {
                selectedDays = []  // Back to "every day"
            }
        } else {
            selectedDays.insert(day)
            // If all 7 are selected, switch to "every day"
            if selectedDays.count == 7 {
                selectedDays = []
            }
        }
    }

    private var scheduleDisplayText: String {
        if selectedDays.isEmpty { return "Every day" }
        let dayNames = ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let sorted = selectedDays.sorted()
        if sorted == [2, 3, 4, 5, 6] { return "Weekdays" }
        if sorted == [1, 7] { return "Weekends" }
        return sorted.map { dayNames[$0] }.joined(separator: ", ")
    }

    // MARK: - Save

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
            habit.stackedAfterHabitId = stackedAfterHabitId
            if purchases.isPremium {
                habit.scheduledDayNumbers = selectedDays
            }
            modelContext.insert(habit)

        case .edit(let habit):
            habit.name = trimmedName
            habit.icon = selectedIcon
            habit.colorHex = selectedColor
            habit.stackedAfterHabitId = stackedAfterHabitId
            if purchases.isPremium {
                habit.scheduledDayNumbers = selectedDays
            }
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Habit Stack Picker
struct HabitStackPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedHabitId: UUID?
    let availableHabits: [Habit]

    var body: some View {
        NavigationStack {
            List {
                // None option
                Button {
                    selectedHabitId = nil
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(Color.secondaryText)

                        Text("No Stack (Independent)")

                        Spacer()

                        if selectedHabitId == nil {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)

                Section("Stack After") {
                    ForEach(availableHabits) { habit in
                        Button {
                            selectedHabitId = habit.id
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: habit.icon)
                                    .foregroundStyle(Color(hex: habit.colorHex))
                                    .frame(width: 32)

                                Text(habit.name)

                                Spacer()

                                if selectedHabitId == habit.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("How Habit Stacking Works", systemImage: "info.circle")
                            .font(.headline)

                        Text("When you complete a habit, you'll be reminded to do the next habit in your stack. This helps build routine chains.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)

                        HStack(spacing: 8) {
                            Text("Example:")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)

                            HStack(spacing: 4) {
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.caption)
                                Text("Coffee")
                                    .font(.caption)
                            }

                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(Color.secondaryText)

                            HStack(spacing: 4) {
                                Image(systemName: "book.fill")
                                    .font(.caption)
                                Text("Read")
                                    .font(.caption)
                            }

                            Image(systemName: "arrow.right")
                                .font(.caption2)
                                .foregroundStyle(Color.secondaryText)

                            HStack(spacing: 4) {
                                Image(systemName: "figure.yoga")
                                    .font(.caption)
                                Text("Stretch")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Stack After")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview("Create") {
    HabitEditorView(mode: .create)
        .modelContainer(for: Habit.self, inMemory: true)
        .preferredColorScheme(.dark)
}
