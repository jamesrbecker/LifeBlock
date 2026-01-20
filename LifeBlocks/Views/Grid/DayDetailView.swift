import SwiftUI
import SwiftData

struct DayDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query private var habits: [Habit]

    let date: Date

    init(date: Date) {
        self.date = date
        let targetDate = Calendar.current.startOfDay(for: date)
        _habits = Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    }

    private var dayScore: Int {
        let completions = habits.compactMap { $0.completion(for: date) }
        return DayEntry.calculateScore(from: completions, totalHabits: habits.count)
    }

    private var completedCount: Int {
        habits.filter { $0.completionLevel(for: date) == 2 }.count
    }

    private var partialCount: Int {
        habits.filter { $0.completionLevel(for: date) == 1 }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Date header with score
                    headerSection

                    // Quick stats
                    statsSection

                    // Habit breakdown
                    habitsSection
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle(DateHelpers.formatDate(date, style: .short))
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

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Large score square
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(GridColorScheme.green.color(for: dayScore, isDarkMode: true))
                    .frame(width: 100, height: 100)

                VStack(spacing: 4) {
                    Text("\(dayScore)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))

                    Text("Level")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .foregroundStyle(.white)
            }

            Text(DateHelpers.formatDate(date, style: .long))
                .font(.headline)
                .foregroundStyle(.secondary)

            // Score description
            Text(scoreDescription)
                .font(.title3)
                .fontWeight(.medium)
        }
        .padding(.vertical)
    }

    private var statsSection: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "Completed",
                value: "\(completedCount)",
                icon: "checkmark.circle.fill",
                color: .green
            )

            StatCard(
                title: "Partial",
                value: "\(partialCount)",
                icon: "circle.lefthalf.filled",
                color: .yellow
            )

            StatCard(
                title: "Skipped",
                value: "\(habits.count - completedCount - partialCount)",
                icon: "xmark.circle.fill",
                color: .secondary
            )
        }
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Breakdown")
                .font(.headline)
                .foregroundStyle(.primary)

            VStack(spacing: 12) {
                ForEach(habits) { habit in
                    HabitCompletionRow(habit: habit, date: date)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var scoreDescription: String {
        switch dayScore {
        case 4: return "Maximum activity!"
        case 3: return "High activity day"
        case 2: return "Moderate activity"
        case 1: return "Light activity"
        default: return "No activity recorded"
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct HabitCompletionRow: View {
    let habit: Habit
    let date: Date

    private var completionLevel: Int {
        habit.completionLevel(for: date)
    }

    var body: some View {
        HStack(spacing: 14) {
            // Habit icon
            Image(systemName: habit.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: habit.colorHex))
                .frame(width: 40)

            // Habit name
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.body)
                    .fontWeight(.medium)

                if let completion = habit.completion(for: date), let notes = completion.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Completion status
            completionBadge
        }
        .padding()
        .background(completionBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var completionBadge: some View {
        switch completionLevel {
        case 2:
            HStack(spacing: 4) {
                Image(systemName: "checkmark.circle.fill")
                Text("Done")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.green)

        case 1:
            HStack(spacing: 4) {
                Image(systemName: "circle.lefthalf.filled")
                Text("Partial")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.yellow)

        default:
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle.fill")
                Text("Skipped")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private var completionBackground: Color {
        switch completionLevel {
        case 2: return Color.green.opacity(0.1)
        case 1: return Color.yellow.opacity(0.1)
        default: return Color.gridBackground
        }
    }
}

#Preview {
    DayDetailView(date: Date())
        .modelContainer(for: [Habit.self, HabitCompletion.self, DayEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
