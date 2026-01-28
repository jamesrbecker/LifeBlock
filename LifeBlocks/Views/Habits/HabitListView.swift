import SwiftUI
import SwiftData

// =============================================================================
// MARK: - HabitListView.swift
// =============================================================================
/// The main view for managing all habits in the app.
///
/// ## Overview
/// This view displays all habits organized into two sections:
/// 1. **Built-in Habits**: System habits that come with the app (free)
/// 2. **Custom Habits**: User-created habits (limited for free users)
///
/// ## Free vs Premium
/// - Free users: Can have up to 3 custom habits
/// - Premium users: Unlimited custom habits
///
/// ## Actions Available
/// - **System habits**: Toggle active/inactive (swipe actions)
/// - **Custom habits**: Edit, delete, reorder (swipe + drag)
/// - **Add new**: Button at bottom of custom habits section
///
/// ## HealthKit Integration
/// Some habits are marked as "Auto-tracked" if they sync with HealthKit
/// (e.g., Exercise, Sleep). These show a heart icon indicator.

struct HabitListView: View {

    // MARK: - Environment & Data

    /// SwiftData model context for saving/deleting habits
    @Environment(\.modelContext) private var modelContext

    /// All habits from SwiftData, sorted by sortOrder (user-defined order)
    @Query(sort: \Habit.sortOrder) private var habits: [Habit]

    // MARK: - State

    /// Controls whether the "Add Habit" sheet is displayed
    @State private var showingAddHabit = false

    /// Controls whether the template library is displayed
    @State private var showingTemplateLibrary = false

    /// The habit currently being edited (nil = not editing)
    /// Used to present the edit sheet
    @State private var editingHabit: Habit?

    /// Subscription status to check custom habit limits
    @ObservedObject private var subscription = SubscriptionStatus.shared

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                // ═══════════════════════════════════════════════════════════════
                // BUILT-IN HABITS SECTION
                // ═══════════════════════════════════════════════════════════════
                // System habits that come with the app
                // Users can enable/disable but not delete these
                Section {
                    ForEach(habits.filter { $0.isSystemHabit }) { habit in
                        HabitRow(habit: habit)
                            // Swipe action: Toggle active/inactive
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

                // ═══════════════════════════════════════════════════════════════
                // HABIT TEMPLATES SECTION
                // ═══════════════════════════════════════════════════════════════
                Section {
                    Button {
                        showingTemplateLibrary = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "rectangle.grid.2x2.fill")
                                .font(.title2)
                                .foregroundStyle(Color.accentSkyBlue)
                                .frame(width: 32)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Browse Habit Templates")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text("Choose from 200+ pre-built habits")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("Free for all users. Find habits tailored to your career or lifestyle.")
                }

                // ═══════════════════════════════════════════════════════════════
                // CUSTOM HABITS SECTION
                // ═══════════════════════════════════════════════════════════════
                // User-created habits (limited for free users)
                Section {
                    ForEach(habits.filter { !$0.isSystemHabit }) { habit in
                        HabitRow(habit: habit)
                            // Swipe actions: Delete and Edit
                            // allowsFullSwipe: false prevents accidental deletes
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                // Delete button (destructive red)
                                Button(role: .destructive) {
                                    deleteHabit(habit)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }

                                // Edit button (blue)
                                Button {
                                    editingHabit = habit
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                    }
                    // Enable drag-to-reorder
                    .onMove(perform: moveHabits)

                    // ═══════════════════════════════════════════════════════════
                    // ADD CUSTOM HABIT BUTTON
                    // ═══════════════════════════════════════════════════════════
                    // Disabled if user has hit free tier limit
                    Button {
                        if subscription.canAddMoreHabits(currentCount: customHabitCount) {
                            showingAddHabit = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(canAddHabit ? Color.accentSkyBlue : .secondary)
                            Text("Add Custom Habit")
                                .foregroundColor(canAddHabit ? .primary : .secondary)
                        }
                    }
                    .disabled(!canAddHabit)
                } header: {
                    HStack {
                        Text("Custom Habits")
                        Spacer()
                        // Show usage counter for free users (e.g., "2/3")
                        if !subscription.isPremium {
                            Text("\(customHabitCount)/\(freeHabitLimit)")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                } footer: {
                    // Upgrade prompt when at limit
                    if !subscription.isPremium && customHabitCount >= freeHabitLimit {
                        Text("Upgrade to Premium for unlimited custom habits.")
                    }
                }
            }
            .navigationTitle("Habits")
            // Edit button in toolbar enables reorder mode
            .toolbar {
                EditButton()
            }
            // Sheet for browsing habit templates
            .sheet(isPresented: $showingTemplateLibrary) {
                HabitTemplateLibraryView()
            }
            // Sheet for creating new habits
            .sheet(isPresented: $showingAddHabit) {
                HabitEditorView(mode: .create)
            }
            // Sheet for editing existing habits
            .sheet(item: $editingHabit) { habit in
                HabitEditorView(mode: .edit(habit))
            }
        }
    }

    // MARK: - Computed Properties

    /// Count of user-created (non-system) habits
    private var customHabitCount: Int {
        habits.filter { !$0.isSystemHabit }.count
    }

    /// The maximum number of custom habits allowed for free users
    /// Premium users have unlimited
    private var freeHabitLimit: Int {
        SubscriptionTier.free.maxCustomHabits
    }

    /// Whether the user can add another custom habit
    /// False if free user has hit their limit
    private var canAddHabit: Bool {
        subscription.canAddMoreHabits(currentCount: customHabitCount)
    }

    // MARK: - Actions

    /// Toggles a habit between active and inactive states.
    /// Inactive habits don't appear on the main grid but data is preserved.
    ///
    /// - Parameter habit: The habit to toggle
    private func toggleHabit(_ habit: Habit) {
        habit.isActive.toggle()
        try? modelContext.save()
    }

    /// Permanently deletes a habit and all its completion data.
    ///
    /// - Parameter habit: The habit to delete
    private func deleteHabit(_ habit: Habit) {
        modelContext.delete(habit)
        try? modelContext.save()
    }

    /// Handles drag-to-reorder for custom habits.
    /// Updates sortOrder for all affected habits.
    ///
    /// - Parameters:
    ///   - source: The indices being moved
    ///   - destination: The target index
    private func moveHabits(from source: IndexSet, to destination: Int) {
        // Get only custom habits (system habits aren't reorderable)
        var customHabits = habits.filter { !$0.isSystemHabit }
        // Apply the move
        customHabits.move(fromOffsets: source, toOffset: destination)

        // Update sortOrder for all custom habits
        // Start after system habits to keep them at the top
        for (index, habit) in customHabits.enumerated() {
            habit.sortOrder = Habit.systemHabits.count + index
        }

        try? modelContext.save()
    }
}

// =============================================================================
// MARK: - HabitRow
// =============================================================================
/// A single row in the habit list displaying habit info.
///
/// ## Display Elements
/// - **Icon**: The habit's SF Symbol in its color
/// - **Name**: The habit title
/// - **Auto-tracked badge**: Shows if habit syncs with HealthKit
/// - **Disabled badge**: Shows if habit is inactive
///
/// Inactive habits are dimmed to 60% opacity.

struct HabitRow: View {

    /// The habit data to display
    let habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            // Habit icon in its custom color
            Image(systemName: habit.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: habit.colorHex))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                // Habit name - dimmed if inactive
                Text(habit.name)
                    .font(.body)
                    .foregroundStyle(habit.isActive ? .primary : .secondary)

                // HealthKit integration indicator
                // Shows a heart icon if this habit auto-tracks from Apple Health
                if habit.healthKitType != nil {
                    Label("Auto-tracked", systemImage: "heart.fill")
                        .font(.caption2)
                        .foregroundStyle(.pink)
                }

                // Schedule indicator for non-daily habits
                if !habit.isEveryDay {
                    Label(habit.scheduleDisplayText, systemImage: "calendar")
                        .font(.caption2)
                        .foregroundStyle(Color.accentSkyBlue)
                }
            }

            Spacer()

            // Disabled badge for inactive habits
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
        // Dim the entire row if habit is inactive
        .opacity(habit.isActive ? 1 : 0.6)
    }
}

#Preview {
    HabitListView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
        .preferredColorScheme(.dark)
}
