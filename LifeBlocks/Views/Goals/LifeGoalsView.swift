import SwiftUI

// MARK: - Life Goals View

struct LifeGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var subscription = SubscriptionStatus.shared
    @State private var showingAddGoal = false
    @State private var showingPremium = false
    @State private var selectedGoal: LifeGoal?
    @State private var goals: [LifeGoal] = AppSettings.shared.lifeGoals

    private var goalsByTimeframe: [GoalTimeframe: [LifeGoal]] {
        Dictionary(grouping: goals.filter { !$0.isCompleted }, by: { $0.timeframe })
    }

    private var activeGoalCount: Int {
        goals.filter { !$0.isCompleted }.count
    }

    private var canAddMoreGoals: Bool {
        subscription.canAddMoreGoals(currentCount: activeGoalCount)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress summary
                    progressSummary

                    // Goals by timeframe
                    ForEach(GoalTimeframe.allCases, id: \.self) { timeframe in
                        if let timeframeGoals = goalsByTimeframe[timeframe], !timeframeGoals.isEmpty {
                            goalSection(timeframe: timeframe, goals: timeframeGoals)
                        }
                    }

                    // Completed goals
                    let completed = goals.filter { $0.isCompleted }
                    if !completed.isEmpty {
                        completedSection(goals: completed)
                    }

                    // Empty state
                    if goals.isEmpty {
                        emptyState
                    }

                    // Premium upsell for free users at limit
                    if !subscription.isPremium && activeGoalCount >= subscription.tier.maxLifeGoals {
                        premiumUpsell
                    }

                    // Add goal button
                    addGoalButton
                }
                .padding()
            }
            .background(Color.gridBackground)
            .navigationTitle("Life Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                AddLifeGoalView { newGoal in
                    AppSettings.shared.addLifeGoal(newGoal)
                    goals = AppSettings.shared.lifeGoals
                }
            }
            .sheet(isPresented: $showingPremium) {
                PremiumView()
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal) { updatedGoal in
                    AppSettings.shared.updateLifeGoal(updatedGoal)
                    goals = AppSettings.shared.lifeGoals
                } onDelete: {
                    AppSettings.shared.deleteLifeGoal(goal)
                    goals = AppSettings.shared.lifeGoals
                }
            }
        }
    }

    // MARK: - Progress Summary

    private var progressSummary: some View {
        HStack(spacing: 16) {
            GoalSummaryCard(
                value: "\(goals.filter { !$0.isCompleted }.count)",
                label: "Active",
                icon: "target",
                color: .blue
            )

            GoalSummaryCard(
                value: "\(goals.filter { $0.isCompleted }.count)",
                label: "Done",
                icon: "checkmark.seal.fill",
                color: .green
            )

            GoalSummaryCard(
                value: "\(Int(averageProgress * 100))%",
                label: "Progress",
                icon: "chart.line.uptrend.xyaxis",
                color: .purple
            )
        }
    }

    private var averageProgress: Double {
        let activeGoals = goals.filter { !$0.isCompleted }
        guard !activeGoals.isEmpty else { return 0 }
        return activeGoals.map { $0.progress }.reduce(0, +) / Double(activeGoals.count)
    }

    // MARK: - Goal Section

    private func goalSection(timeframe: GoalTimeframe, goals: [LifeGoal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: timeframe.icon)
                    .foregroundStyle(timeframe.color)
                Text(timeframe.displayName)
                    .font(.headline)
                Text("(\(timeframe.subtitle))")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            ForEach(goals) { goal in
                GoalCard(goal: goal)
                    .onTapGesture {
                        selectedGoal = goal
                    }
            }
        }
    }

    // MARK: - Completed Section

    private func completedSection(goals: [LifeGoal]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                Text("Completed")
                    .font(.headline)
            }

            ForEach(goals.prefix(3)) { goal in
                CompletedGoalRow(goal: goal)
                    .onTapGesture {
                        selectedGoal = goal
                    }
            }

            if goals.count > 3 {
                Text("+ \(goals.count - 3) more completed")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundStyle(Color.secondaryText)

            Text("Set Your Life Goals")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Define what matters most to you.\nShort-term wins lead to long-term success.")
                .font(.body)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }

    // MARK: - Add Goal Button

    private var addGoalButton: some View {
        Button {
            HapticManager.shared.mediumTap()
            if canAddMoreGoals {
                showingAddGoal = true
            } else {
                showingPremium = true
            }
        } label: {
            HStack {
                Image(systemName: canAddMoreGoals ? "plus.circle.fill" : "lock.fill")
                    .font(.title2)
                Text(canAddMoreGoals ? "Add Life Goal" : "Upgrade for More Goals")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canAddMoreGoals ? Color.accentGreen : Color.purple)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Premium Upsell

    private var premiumUpsell: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("Unlock Unlimited Goals")
                    .font(.headline)
            }

            Text("Free users can set 1 life goal. Upgrade to Premium for unlimited goals and track your entire life journey.")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)

            Button {
                showingPremium = true
            } label: {
                Text("See Premium")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple)
                    .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Goal Summary Card

struct GoalSummaryCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Goal Card

struct GoalCard: View {
    let goal: LifeGoal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundStyle(goal.category.color)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(goal.title)
                        .font(.headline)
                        .lineLimit(1)

                    Text(goal.category.displayName)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if let days = goal.daysRemaining {
                    VStack(alignment: .trailing) {
                        Text("\(abs(days))")
                            .font(.headline)
                            .foregroundStyle(goal.isOverdue ? .red : .primary)
                        Text(days >= 0 ? "days left" : "days over")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }

            if !goal.description.isEmpty {
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(2)
            }

            // Progress bar
            if !goal.milestones.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(goal.milestones.filter { $0.isCompleted }.count)/\(goal.milestones.count) milestones")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                        Spacer()
                        Text("\(goal.progressPercentage)%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentGreen)
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentGreen)
                                .frame(width: geometry.size.width * goal.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Completed Goal Row

struct CompletedGoalRow: View {
    let goal: LifeGoal

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text(goal.title)
                .strikethrough()
                .foregroundStyle(Color.secondaryText)

            Spacer()

            if let date = goal.completedDate {
                Text(date, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding()
        .background(Color.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Add Life Goal View

struct AddLifeGoalView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (LifeGoal) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var timeframe: GoalTimeframe = .mediumTerm
    @State private var category: GoalCategory = .personal
    @State private var hasTargetDate = false
    @State private var targetDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
    @State private var showingTemplates = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Goal title", text: $title)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Category") {
                    Picker("Category", selection: $category) {
                        ForEach(GoalCategory.allCases, id: \.self) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Timeframe") {
                    Picker("Timeframe", selection: $timeframe) {
                        ForEach(GoalTimeframe.allCases, id: \.self) { tf in
                            HStack {
                                Image(systemName: tf.icon)
                                Text("\(tf.displayName) (\(tf.subtitle))")
                            }
                            .tag(tf)
                        }
                    }
                    .pickerStyle(.menu)

                    Toggle("Set target date", isOn: $hasTargetDate)

                    if hasTargetDate {
                        DatePicker("Target date", selection: $targetDate, displayedComponents: .date)
                    }
                }

                Section {
                    Button {
                        showingTemplates = true
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Browse Goal Ideas")
                        }
                    }
                }
            }
            .navigationTitle("New Life Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let goal = LifeGoal(
                            title: title,
                            description: description,
                            timeframe: timeframe,
                            category: category,
                            targetDate: hasTargetDate ? targetDate : nil
                        )
                        onAdd(goal)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingTemplates) {
                GoalTemplatesView { template in
                    title = template.title
                    description = template.description
                    timeframe = template.timeframe
                    category = template.category
                    showingTemplates = false
                }
            }
        }
    }
}

// MARK: - Goal Templates View

struct GoalTemplatesView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (LifeGoal) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(GoalCategory.allCases, id: \.self) { category in
                    if let templates = LifeGoalTemplates.templates[category] {
                        Section {
                            ForEach(templates) { template in
                                Button {
                                    onSelect(template)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Image(systemName: template.category.icon)
                                            .foregroundStyle(template.category.color)
                                            .frame(width: 30)

                                        VStack(alignment: .leading) {
                                            Text(template.title)
                                                .foregroundStyle(.primary)
                                            Text(template.timeframe.displayName)
                                                .font(.caption)
                                                .foregroundStyle(Color.secondaryText)
                                        }
                                    }
                                }
                            }
                        } header: {
                            Label(category.displayName, systemImage: category.icon)
                        }
                    }
                }
            }
            .navigationTitle("Goal Ideas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Goal Detail View

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var goal: LifeGoal
    let onUpdate: (LifeGoal) -> Void
    let onDelete: () -> Void

    @State private var newMilestoneTitle = ""
    @State private var showingDeleteConfirm = false

    var body: some View {
        NavigationStack {
            List {
                // Goal info
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: goal.category.icon)
                                .foregroundStyle(goal.category.color)
                            Text(goal.category.displayName)
                                .foregroundStyle(Color.secondaryText)
                        }
                        .font(.subheadline)

                        Text(goal.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if !goal.description.isEmpty {
                            Text(goal.description)
                                .foregroundStyle(Color.secondaryText)
                        }

                        HStack {
                            Image(systemName: goal.timeframe.icon)
                            Text(goal.timeframe.displayName)
                            if let date = goal.targetDate {
                                Text("- Due \(date, style: .date)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                    }
                    .padding(.vertical, 8)
                }

                // Progress
                if !goal.milestones.isEmpty {
                    Section("Progress - \(goal.progressPercentage)%") {
                        ForEach($goal.milestones) { $milestone in
                            HStack {
                                Button {
                                    milestone.isCompleted.toggle()
                                    if milestone.isCompleted {
                                        milestone.completedDate = Date()
                                    }
                                    onUpdate(goal)
                                } label: {
                                    Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(milestone.isCompleted ? .green : .secondary)
                                }

                                Text(milestone.title)
                                    .strikethrough(milestone.isCompleted)
                            }
                        }
                    }
                }

                // Add milestone
                Section("Milestones") {
                    HStack {
                        TextField("Add milestone...", text: $newMilestoneTitle)
                        Button {
                            let milestone = GoalMilestone(title: newMilestoneTitle)
                            goal.milestones.append(milestone)
                            newMilestoneTitle = ""
                            onUpdate(goal)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.accentGreen)
                        }
                        .disabled(newMilestoneTitle.isEmpty)
                    }
                }

                // Mark complete
                Section {
                    Button {
                        goal.isCompleted = true
                        goal.completedDate = Date()
                        onUpdate(goal)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Mark Goal Complete")
                        }
                        .foregroundStyle(.green)
                    }
                }

                // Delete
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Goal")
                        }
                    }
                }
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Delete Goal?", isPresented: $showingDeleteConfirm) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LifeGoalsView()
        .preferredColorScheme(.dark)
}
