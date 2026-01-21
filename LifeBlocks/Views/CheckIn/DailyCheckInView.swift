import SwiftUI
import SwiftData

struct DailyCheckInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(filter: #Predicate<Habit> { $0.isActive }, sort: \Habit.sortOrder)
    private var habits: [Habit]

    @State private var currentIndex: Int = 0
    @State private var answers: [UUID: Int] = [:]
    @State private var isComplete: Bool = false
    @State private var showingResults: Bool = false

    let date: Date

    init(date: Date = Date()) {
        self.date = date
    }

    private var progress: Double {
        guard !habits.isEmpty else { return 0 }
        return Double(currentIndex) / Double(habits.count)
    }

    private var totalScore: Int {
        DayEntry.calculateScore(
            from: answers.map { HabitCompletion(date: date, completionLevel: $0.value) },
            totalHabits: habits.count
        )
    }

    var body: some View {
        ZStack {
            Color.gridBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding()

                if showingResults {
                    resultsView
                } else if habits.isEmpty {
                    emptyStateView
                } else {
                    // Card stack
                    cardStackView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(DateHelpers.formatDate(date, style: .relative))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                // Invisible spacer for alignment
                Image(systemName: "xmark")
                    .font(.title3)
                    .opacity(0)
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.borderColor)
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentGreen)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 8)

            Text("\(currentIndex)/\(habits.count) completed")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var cardStackView: some View {
        ZStack {
            // Background cards (stacked effect)
            ForEach(Array(habits.enumerated().reversed()), id: \.element.id) { index, habit in
                if index >= currentIndex && index < currentIndex + 3 {
                    let offset = index - currentIndex

                    QuestionCardView(habit: habit) { answer in
                        recordAnswer(for: habit, answer: answer)
                    }
                    .offset(y: CGFloat(offset) * 8)
                    .scaleEffect(1 - CGFloat(offset) * 0.05)
                    .opacity(offset == 0 ? 1 : 0.5)
                    .zIndex(Double(habits.count - index))
                    .allowsHitTesting(offset == 0)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()

            // Score display
            VStack(spacing: 16) {
                Text("Today's Score")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .fill(GridColorScheme.green.color(for: totalScore, isDarkMode: true))
                        .frame(width: 120, height: 120)

                    VStack {
                        Text("\(totalScore)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("/ 4")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(scoreMessage)
                    .font(.title3)
                    .fontWeight(.medium)
            }

            // Summary
            VStack(spacing: 12) {
                ForEach(habits) { habit in
                    HStack {
                        Image(systemName: habit.icon)
                            .foregroundStyle(Color(hex: habit.colorHex))
                            .frame(width: 30)

                        Text(habit.name)
                            .font(.subheadline)

                        Spacer()

                        completionBadge(for: answers[habit.id] ?? 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // Done button
            Button {
                saveAndDismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No habits to track")
                .font(.title2)
                .fontWeight(.medium)

            Text("Add some habits in Settings to start tracking your progress.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button("Dismiss") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private func completionBadge(for level: Int) -> some View {
        Group {
            switch level {
            case 2:
                Label("Done", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
            case 1:
                Label("Partial", systemImage: "circle.lefthalf.filled")
                    .font(.caption)
                    .foregroundStyle(.yellow)
            default:
                Label("Skipped", systemImage: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var scoreMessage: String {
        switch totalScore {
        case 4: return "Perfect day!"
        case 3: return "Great progress!"
        case 2: return "Good effort!"
        case 1: return "Keep going!"
        default: return "Tomorrow's a new day!"
        }
    }

    private func recordAnswer(for habit: Habit, answer: Int) {
        answers[habit.id] = answer

        withAnimation(.spring()) {
            if currentIndex < habits.count - 1 {
                currentIndex += 1
            } else {
                // Celebrate completion based on score
                if totalScore == 4 {
                    HapticManager.shared.celebration()
                } else if totalScore >= 2 {
                    HapticManager.shared.success()
                } else {
                    HapticManager.shared.mediumTap()
                }
                showingResults = true
            }
        }
    }

    private func saveAndDismiss() {
        // Save completions to database
        let targetDate = date.startOfDay

        for habit in habits {
            let level = answers[habit.id] ?? 0
            let completion = HabitCompletion(date: targetDate, completionLevel: level)
            completion.habit = habit
            modelContext.insert(completion)
        }

        // Update or create day entry
        let fetchDescriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { $0.date == targetDate }
        )

        do {
            let existingEntries = try modelContext.fetch(fetchDescriptor)
            let entry = existingEntries.first ?? DayEntry(date: targetDate)

            if existingEntries.isEmpty {
                modelContext.insert(entry)
            }

            entry.totalScore = totalScore
            entry.checkedIn = true
            entry.checkedInAt = Date()

            try modelContext.save()

            // Update streak
            AppSettings.shared.updateStreak(checkedInToday: true)
            AppSettings.shared.todayScore = totalScore

        } catch {
            print("Error saving check-in: \(error)")
        }

        dismiss()
    }
}

#Preview {
    DailyCheckInView()
        .modelContainer(for: [Habit.self, HabitCompletion.self, DayEntry.self], inMemory: true)
        .preferredColorScheme(.dark)
}
