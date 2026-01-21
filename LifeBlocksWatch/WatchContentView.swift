import SwiftUI
import WatchKit

struct WatchContentView: View {
    @EnvironmentObject var connectivity: WatchConnectivityManager
    @State private var showingQuickCheckIn = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Streak Display
                    StreakCard(streak: connectivity.currentStreak, checkedInToday: connectivity.checkedInToday)

                    // Quick Check-in Button
                    if !connectivity.checkedInToday {
                        Button {
                            showingQuickCheckIn = true
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Quick Check-in")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("All done today!")
                                .font(.headline)
                        }
                        .padding(.vertical, 12)
                    }

                    // Habits List
                    if !connectivity.habits.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Habits")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            ForEach(connectivity.habits) { habit in
                                HabitRow(habit: habit) { completed in
                                    WKInterfaceDevice.current().play(.click)
                                    connectivity.sendCheckIn(habitId: habit.id, completed: completed)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("LifeBlocks")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingQuickCheckIn) {
                QuickCheckInView()
                    .environmentObject(connectivity)
            }
            .onAppear {
                connectivity.requestSync()
            }
        }
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let streak: Int
    let checkedInToday: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.title2)
                    .foregroundColor(.orange)

                Text("\(streak)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("day streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !checkedInToday && streak > 0 {
                Text("Check in to keep your streak!")
                    .font(.caption2)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Habit Row

struct HabitRow: View {
    let habit: WatchHabit
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!habit.isCompletedToday)
        } label: {
            HStack {
                Image(systemName: habit.icon)
                    .font(.body)
                    .foregroundColor(Color(hex: habit.colorHex))
                    .frame(width: 24)

                Text(habit.name)
                    .font(.caption)
                    .lineLimit(1)

                Spacer()

                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedToday ? .green : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Check-In View

struct QuickCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var connectivity: WatchConnectivityManager

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Quick Check-in")
                    .font(.headline)
                    .padding(.bottom, 8)

                ForEach(connectivity.habits) { habit in
                    QuickCheckInRow(habit: habit) { completed in
                        WKInterfaceDevice.current().play(.click)
                        connectivity.sendCheckIn(habitId: habit.id, completed: completed)
                    }
                }

                Button {
                    // Mark all as complete
                    for habit in connectivity.habits where !habit.isCompletedToday {
                        connectivity.sendCheckIn(habitId: habit.id, completed: true)
                    }
                    WKInterfaceDevice.current().play(.success)
                    dismiss()
                } label: {
                    Text("Complete All")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
            .padding()
        }
    }
}

struct QuickCheckInRow: View {
    let habit: WatchHabit
    let onToggle: (Bool) -> Void

    var body: some View {
        Button {
            onToggle(!habit.isCompletedToday)
        } label: {
            HStack {
                Image(systemName: habit.icon)
                    .foregroundColor(Color(hex: habit.colorHex))

                Text(habit.name)
                    .font(.caption)

                Spacer()

                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
            }
            .padding(10)
            .background(habit.isCompletedToday ? Color.green.opacity(0.2) : Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Extension for Watch

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    WatchContentView()
        .environmentObject(WatchConnectivityManager.shared)
}
