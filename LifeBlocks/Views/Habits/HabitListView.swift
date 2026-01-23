import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    @State private var showingAddHabit = false
    @State private var editingHabit: Habit?

    @ObservedObject private var subscription = SubscriptionStatus.shared

    var body: some View {
        NavigationStack {
            List {
                // System habits section
                Section {
                    ForEach(habits.filter { $0.isSystemHabit }) { habit in
                        HabitRow(habit: habit)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    toggleHabit(habit)
                                } label: {
                                    Label(
                                        habit.isActive ? "Disable" : "Enable",
                                        systemImage: habit.isActive ? "eye.slash" : "eye"
                                    )
                                }
                                .tint(habit.isActive ? .orange : .green)
                            }
                    }
                } header: {
                    Text("Built-in Habits")
                } footer: {
                    Text("These habits are included with the free version.")
                }

                // Custom habits section
                Section {
                    ForEach(habits.filter { !$0.isSystemHabit }) { habit in
                        HabitRow(habit: habit)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    deleteHabit(habit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                Button {
                                    editingHabit = habit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    .onMove(perform: moveHabits)

                    // Add button
                    Button {
                        if subscription.canAddMoreHabits(currentCount: customHabitCount) {
                            showingAddHabit = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(canAddHabit ? Color.accentGreen : .secondary)
                            Text("Add Custom Habit")
                                .foregroundColor(canAddHabit ? .primary : .secondary)
                        }
                    }
                    .disabled(!canAddHabit)
                } header: {
                    HStack {
                        Text("Custom Habits")
                        Spacer()
                        if !subscription.isPremium {
                            Text("\(customHabitCount)/\(freeHabitLimit)")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                } footer: {
                    if !subscription.isPremium && customHabitCount >= freeHabitLimit {
                        Text("Upgrade to Premium for unlimited custom habits.")
                    }
                }
            }
            .navigationTitle("Habits")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showingAddHabit) {
                HabitEditorView(mode: .create)
            }
            .sheet(item: $editingHabit) { habit in
                HabitEditorView(mode: .edit(habit))
            }
        }
    }

    private var customHabitCount: Int {
        habits.filter { !$0.isSystemHabit }.count
    }

    private var freeHabitLimit: Int {
        SubscriptionTier.free.maxCustomHabits
    }

    private var canAddHabit: Bool {
        subscription.canAddMoreHabits(currentCount: customHabitCount)
    }

    private func toggleHabit(_ habit: Habit) {
        habit.isActive.toggle()
        try? modelContext.save()
    }

    private func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
    }

    private func moveHabits(from source: IndexSet, to destination: Int) {
        var customHabits = habits.filter { !$0.isSystemHabit }
        customHabits.move(fromOffsets: source, toOffset: destination)

        for (index, habit) in customHabits.enumerated() {
            habit.sortOrder = Habit.systemHabits.count + index
        }

        try? modelContext.save()
    }
}

struct HabitRow: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: habit.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: habit.colorHex))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .foregroundStyle(habit.isActive ? .primary : .secondary)

                if habit.healthKitType != nil {
                    Label("Auto-tracked", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.pink)
                }
            }

            Spacer()

            if !habit.isActive {
                Text("Disabled")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
        .opacity(habit.isActive ? 1 : 0.6)
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
        .preferredColorScheme(.dark)
}
