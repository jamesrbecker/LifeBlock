import SwiftUI

// MARK: - Watch Content View
/// Main view for Apple Watch companion app

struct WatchContentView: View {
    @State private var todayCheckedIn = false
    @State private var currentStreak = 0
    @State private var habits: [WatchHabit] = []
    @State private var showingCheckIn = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Streak Badge
                    StreakBadgeWatch(streak: currentStreak)

                    // Today's Status
                    TodayStatusCard(
                        checkedIn: todayCheckedIn,
                        onCheckIn: { showingCheckIn = true }
                    )

                    // Mini Grid Preview
                    MiniGridWatch()
                }
                .padding()
            }
            .navigationTitle("LifeBlocks")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCheckIn) {
                QuickCheckInView(
                    habits: habits,
                    onComplete: {
                        todayCheckedIn = true
                        currentStreak += 1
                        showingCheckIn = false
                    }
                )
            }
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        // Load from shared UserDefaults (App Groups)
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app")
        currentStreak = defaults?.integer(forKey: "currentStreak") ?? 0

        // Check if already checked in today
        if let lastCheckIn = defaults?.object(forKey: "lastCheckInDate") as? Date {
            todayCheckedIn = Calendar.current.isDateInToday(lastCheckIn)
        }

        // Load habit names (simplified for watch)
        habits = [
            WatchHabit(name: "Exercise", icon: "figure.run"),
            WatchHabit(name: "Read", icon: "book.fill"),
            WatchHabit(name: "Meditate", icon: "brain.head.profile"),
            WatchHabit(name: "Learn", icon: "lightbulb.fill"),
            WatchHabit(name: "Create", icon: "paintbrush.fill")
        ]
    }
}

// MARK: - Watch Habit Model

struct WatchHabit: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    var completed: Bool = false
}

// MARK: - Streak Badge Watch

struct StreakBadgeWatch: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
            Text("\(streak)")
                .fontWeight(.bold)
            Text("day streak")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.2))
        .clipShape(Capsule())
    }
}

// MARK: - Today Status Card

struct TodayStatusCard: View {
    let checkedIn: Bool
    let onCheckIn: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            if checkedIn {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(.green)

                Text("Checked In!")
                    .font(.headline)

                Text("Great work today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "circle")
                    .font(.title)
                    .foregroundStyle(.gray)

                Text("Not Checked In")
                    .font(.headline)

                Button(action: onCheckIn) {
                    Text("Check In Now")
                        .font(.caption)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Mini Grid Watch

struct MiniGridWatch: View {
    // Last 7 days preview
    let lastWeek: [Int] = [3, 4, 2, 4, 3, 0, 0] // Example data

    var body: some View {
        VStack(spacing: 4) {
            Text("This Week")
                .font(.caption2)
                .foregroundStyle(.secondary)

            HStack(spacing: 2) {
                ForEach(0..<7, id: \.self) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(lastWeek[day]))
                        .frame(width: 16, height: 16)
                }
            }

            HStack {
                Text("Mon")
                Spacer()
                Text("Sun")
            }
            .font(.system(size: 8))
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.gray.opacity(0.3)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green
        default: return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Quick Check In View

struct QuickCheckInView: View {
    let habits: [WatchHabit]
    let onComplete: () -> Void

    @State private var completedHabits: Set<UUID> = []
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Quick Check-In")
                    .font(.headline)

                ForEach(habits) { habit in
                    HabitRowWatch(
                        habit: habit,
                        isCompleted: completedHabits.contains(habit.id),
                        onToggle: {
                            if completedHabits.contains(habit.id) {
                                completedHabits.remove(habit.id)
                            } else {
                                completedHabits.insert(habit.id)
                            }
                        }
                    )
                }

                Button(action: {
                    saveCheckIn()
                    onComplete()
                }) {
                    Text("Done")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top)
            }
            .padding()
        }
    }

    private func saveCheckIn() {
        let defaults = UserDefaults(suiteName: "group.com.lifeblock.app")
        defaults?.set(Date(), forKey: "lastCheckInDate")

        // Update streak
        let currentStreak = (defaults?.integer(forKey: "currentStreak") ?? 0) + 1
        defaults?.set(currentStreak, forKey: "currentStreak")

        let longestStreak = defaults?.integer(forKey: "longestStreak") ?? 0
        if currentStreak > longestStreak {
            defaults?.set(currentStreak, forKey: "longestStreak")
        }
    }
}

// MARK: - Habit Row Watch

struct HabitRowWatch: View {
    let habit: WatchHabit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack {
                Image(systemName: habit.icon)
                    .foregroundStyle(isCompleted ? .green : .gray)

                Text(habit.name)
                    .font(.caption)

                Spacer()

                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isCompleted ? .green : .gray)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isCompleted ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    WatchContentView()
}
