import SwiftUI

// MARK: - Sprint Dashboard View

struct SprintDashboardView: View {
    @State private var activeSprints: [Sprint] = AppSettings.shared.activeSprints
    @State private var showCreateSprint = false
    @State private var selectedSprint: Sprint?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Sprints")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primaryText)

                        Text("Short-term accelerators for your path")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    Button {
                        showCreateSprint = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.accentGreen)
                    }
                }
                .padding(.horizontal)

                if activeSprints.isEmpty {
                    EmptySprintView {
                        showCreateSprint = true
                    }
                } else {
                    // Active Sprints
                    ForEach(activeSprints.filter { $0.isActive && !$0.isCompleted }) { sprint in
                        SprintCard(sprint: sprint) {
                            selectedSprint = sprint
                        }
                    }

                    // Completed Sprints
                    let completed = activeSprints.filter { $0.isCompleted }
                    if !completed.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Completed")
                                .font(.headline)
                                .foregroundStyle(Color.secondaryText)
                                .padding(.horizontal)

                            ForEach(completed) { sprint in
                                CompletedSprintCard(sprint: sprint)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color.gridBackground)
        .sheet(isPresented: $showCreateSprint) {
            CreateSprintView { newSprint in
                activeSprints.append(newSprint)
                AppSettings.shared.activeSprints = activeSprints
            }
        }
        .sheet(item: $selectedSprint) { sprint in
            SprintDetailView(sprint: sprint) { updatedSprint in
                if let index = activeSprints.firstIndex(where: { $0.id == updatedSprint.id }) {
                    activeSprints[index] = updatedSprint
                    AppSettings.shared.activeSprints = activeSprints
                }
            }
        }
    }
}

// MARK: - Empty Sprint View

struct EmptySprintView: View {
    let onCreateTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bolt.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 8) {
                Text("No Active Sprints")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                Text("Sprints are focused short-term goals that\naccelerate your progress on your main path.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Button(action: onCreateTap) {
                HStack {
                    Image(systemName: "plus")
                    Text("Start a Sprint")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

// MARK: - Sprint Card

struct SprintCard: View {
    let sprint: Sprint
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    ZStack {
                        Circle()
                            .fill(sprint.color.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: sprint.icon)
                            .font(.title3)
                            .foregroundStyle(sprint.color)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(sprint.name)
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)
                            .lineLimit(1)

                        Text(sprint.durationDescription)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    // Days remaining badge
                    VStack(spacing: 2) {
                        Text("\(sprint.daysRemaining)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(sprint.daysRemaining <= 7 ? .orange : Color.primaryText)

                        Text("days left")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                // Progress bar
                VStack(alignment: .leading, spacing: 6) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.borderColor)
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [sprint.color, sprint.color.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * sprint.progress, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(sprint.progress * 100))% complete")
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText)
                }

                // Metrics preview (show first 2)
                if !sprint.targetMetrics.isEmpty {
                    HStack(spacing: 12) {
                        ForEach(sprint.targetMetrics.prefix(3)) { metric in
                            MetricBadge(metric: metric, color: sprint.color)
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(sprint.color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

// MARK: - Metric Badge

struct MetricBadge: View {
    let metric: SprintMetric
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: metric.icon)
                    .font(.caption2)
                    .foregroundStyle(color)

                Text(metric.name)
                    .font(.caption2)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(1)
            }

            Text(metric.displayValue)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color.primaryText)

            // Mini progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.borderColor)
                        .frame(height: 3)

                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geometry.size.width * metric.progress, height: 3)
                }
            }
            .frame(height: 3)
            .frame(width: 50)
        }
        .padding(8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Completed Sprint Card

struct CompletedSprintCard: View {
    let sprint: Sprint

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 2) {
                Text(sprint.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primaryText)
                    .strikethrough(true, color: Color.secondaryText)

                if let completed = sprint.completedDate {
                    Text("Completed \(completed, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.cardBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Create Sprint View

struct CreateSprintView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Sprint) -> Void

    @State private var selectedCategory: SprintCategory = .college
    @State private var sprintName = ""
    @State private var duration = 30 // days

    // College-specific
    @State private var selectedCollege: CollegeInfo?
    @State private var currentGPA = 3.5
    @State private var currentSAT = 1200
    @State private var collegeSearchText = ""

    // Career-specific
    @State private var selectedCareerPath: CareerPath?
    @State private var currentLevel: CareerLevel?
    @State private var targetLevel: CareerLevel?

    // Fitness-specific
    @State private var fitnessGoal = ""
    @State private var currentWeight = 150.0
    @State private var targetWeight = 150.0

    // Financial
    @State private var targetAmount = 1000.0
    @State private var financialPurpose = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Category selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sprint Type")
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(SprintCategory.allCases.filter { $0 != .custom }, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.horizontal)

                    // Category-specific content
                    Group {
                        switch selectedCategory {
                        case .college:
                            CollegeSprintForm(
                                selectedCollege: $selectedCollege,
                                currentGPA: $currentGPA,
                                currentSAT: $currentSAT,
                                searchText: $collegeSearchText
                            )
                        case .career:
                            CareerSprintForm(
                                selectedPath: $selectedCareerPath,
                                currentLevel: $currentLevel,
                                targetLevel: $targetLevel
                            )
                        case .fitness:
                            FitnessSprintForm(
                                goal: $fitnessGoal,
                                currentWeight: $currentWeight,
                                targetWeight: $targetWeight
                            )
                        case .financial:
                            FinancialSprintForm(
                                targetAmount: $targetAmount,
                                purpose: $financialPurpose
                            )
                        default:
                            CustomSprintForm(
                                name: $sprintName,
                                duration: $duration
                            )
                        }
                    }
                    .padding(.horizontal)

                    // Duration selector (if not auto-set)
                    if selectedCategory != .college && selectedCategory != .career {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Duration")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)

                            HStack(spacing: 12) {
                                DurationButton(days: 7, label: "1 Week", selected: duration == 7) { duration = 7 }
                                DurationButton(days: 30, label: "30 Days", selected: duration == 30) { duration = 30 }
                                DurationButton(days: 60, label: "60 Days", selected: duration == 60) { duration = 60 }
                                DurationButton(days: 90, label: "90 Days", selected: duration == 90) { duration = 90 }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 100)
                }
                .padding(.vertical)
            }
            .background(Color.gridBackground)
            .navigationTitle("New Sprint")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createSprint()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canCreate ? Color.accentGreen : Color.secondaryText)
                    .disabled(!canCreate)
                }
            }
        }
    }

    private var canCreate: Bool {
        switch selectedCategory {
        case .college:
            return selectedCollege != nil
        case .career:
            return currentLevel != nil && targetLevel != nil
        case .fitness:
            return true
        case .financial:
            return targetAmount > 0
        default:
            return !sprintName.isEmpty
        }
    }

    private func createSprint() {
        var sprint: Sprint

        switch selectedCategory {
        case .college:
            guard let college = selectedCollege else { return }
            sprint = SprintTemplates.collegeAdmissionSprint(
                targetCollege: college,
                currentGPA: currentGPA,
                currentSAT: currentSAT,
                monthsUntilApplication: 6
            )
            // Save target college
            AppSettings.shared.targetCollege = college

        case .career:
            guard let current = currentLevel, let target = targetLevel else { return }
            sprint = SprintTemplates.careerAdvancementSprint(
                currentLevel: current,
                targetLevel: target,
                monthsToTarget: duration / 30
            )

        case .fitness:
            sprint = SprintTemplates.fitnessTransformationSprint(
                goal: fitnessGoal,
                targetWeight: targetWeight,
                currentWeight: currentWeight
            )

        case .financial:
            sprint = SprintTemplates.financialSprint(
                targetAmount: targetAmount,
                purpose: financialPurpose
            )

        default:
            sprint = Sprint(
                name: sprintName,
                description: "Custom sprint goal",
                targetDate: Calendar.current.date(byAdding: .day, value: duration, to: Date()) ?? Date(),
                startDate: Date(),
                icon: selectedCategory.icon,
                colorHex: "#808080",
                category: selectedCategory,
                targetMetrics: [],
                linkedHabits: []
            )
        }

        onSave(sprint)
        dismiss()
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let category: SprintCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : category.color)

                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? category.color : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? category.color : Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Duration Button

struct DurationButton: View {
    let days: Int
    let label: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(selected ? .white : Color.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? Color.accentGreen : Color.cardBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(selected ? Color.accentGreen : Color.borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - College Sprint Form

struct CollegeSprintForm: View {
    @Binding var selectedCollege: CollegeInfo?
    @Binding var currentGPA: Double
    @Binding var currentSAT: Int
    @Binding var searchText: String

    @State private var showCollegeSearch = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Target College
            VStack(alignment: .leading, spacing: 8) {
                Text("Target College")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                Button {
                    showCollegeSearch = true
                } label: {
                    HStack {
                        if let college = selectedCollege {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(college.shortName)
                                    .font(.headline)
                                    .foregroundStyle(Color.primaryText)

                                Text(college.gpaDescription + " | " + college.satDescription)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        } else {
                            Text("Select a college...")
                                .foregroundStyle(Color.secondaryText)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundStyle(Color.tertiaryText)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }

            // Current GPA
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current GPA")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Spacer()

                    Text(String(format: "%.2f", currentGPA))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentGreen)
                }

                Slider(value: $currentGPA, in: 1.0...4.3, step: 0.01)
                    .tint(Color.accentGreen)
            }

            // Current SAT
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current SAT")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Spacer()

                    Text("\(currentSAT)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.blue)
                }

                Slider(value: Binding(
                    get: { Double(currentSAT) },
                    set: { currentSAT = Int($0) }
                ), in: 400...1600, step: 10)
                    .tint(Color.blue)
            }

            // Gap Analysis
            if let college = selectedCollege {
                GapAnalysisView(
                    college: college,
                    currentGPA: currentGPA,
                    currentSAT: currentSAT
                )
            }
        }
        .sheet(isPresented: $showCollegeSearch) {
            CollegeSearchView(selectedCollege: $selectedCollege)
        }
    }
}

// MARK: - Gap Analysis View

struct GapAnalysisView: View {
    let college: CollegeInfo
    let currentGPA: Double
    let currentSAT: Int

    var gpaGap: Double {
        max(0, college.avgGPA - currentGPA)
    }

    var satGap: Int {
        max(0, college.avgSAT - currentSAT)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gap Analysis")
                .font(.headline)
                .foregroundStyle(Color.primaryText)

            HStack(spacing: 16) {
                // GPA Gap
                VStack(spacing: 4) {
                    Text(gpaGap == 0 ? "On Track" : String(format: "+%.2f", gpaGap))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(gpaGap == 0 ? .green : .orange)

                    Text("GPA Needed")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // SAT Gap
                VStack(spacing: 4) {
                    Text(satGap == 0 ? "On Track" : "+\(satGap)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(satGap == 0 ? .green : .orange)

                    Text("SAT Needed")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Study Hours Recommendation
            let weeklyHours = 15 + Int(gpaGap * 10) + (satGap / 50)
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)

                Text("Recommended: \(weeklyHours) hours/week of focused study")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

// MARK: - College Search View

struct CollegeSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedCollege: CollegeInfo?

    @State private var searchText = ""
    @State private var selectedType: CollegeType?

    private var filteredColleges: [CollegeInfo] {
        var results = CollegeDatabase.colleges

        if let type = selectedType {
            results = results.filter { $0.type == type }
        }

        if !searchText.isEmpty {
            results = CollegeDatabase.search(query: searchText)
        }

        return results.sorted { ($0.ranking ?? 999) < ($1.ranking ?? 999) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.secondaryText)

                    TextField("Search colleges...", text: $searchText)
                        .foregroundStyle(Color.primaryText)
                }
                .padding()
                .background(Color.cardBackground)

                // Type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: selectedType == nil) {
                            selectedType = nil
                        }

                        ForEach(CollegeType.allCases, id: \.self) { type in
                            FilterChip(title: type.displayName, isSelected: selectedType == type) {
                                selectedType = type
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color.cardBackground)

                // Results
                List(filteredColleges) { college in
                    CollegeRow(college: college) {
                        selectedCollege = college
                        dismiss()
                    }
                    .listRowBackground(Color.gridBackground)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .background(Color.gridBackground)
            .navigationTitle("Select College")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondaryText)
                }
            }
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(isSelected ? .white : Color.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentGreen : Color.borderColor)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - College Row

struct CollegeRow: View {
    let college: CollegeInfo
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Ranking badge
                if let ranking = college.ranking {
                    Text("#\(ranking)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(college.difficulty.color)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.borderColor)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "graduationcap")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        )
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(college.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.primaryText)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        Text(college.location)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)

                        Text("•")
                            .foregroundStyle(Color.tertiaryText)

                        Text("\(Int(college.acceptanceRate))% acceptance")
                            .font(.caption)
                            .foregroundStyle(college.difficulty.color)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(college.gpaDescription)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)

                    Text(college.satDescription)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Career Sprint Form

struct CareerSprintForm: View {
    @Binding var selectedPath: CareerPath?
    @Binding var currentLevel: CareerLevel?
    @Binding var targetLevel: CareerLevel?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Career Path
            VStack(alignment: .leading, spacing: 8) {
                Text("Career Path")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(CareerDatabase.paths) { path in
                            CareerPathButton(
                                path: path,
                                isSelected: selectedPath?.id == path.id
                            ) {
                                selectedPath = path
                                currentLevel = nil
                                targetLevel = nil
                            }
                        }
                    }
                }
            }

            if let path = selectedPath {
                // Current Level
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Level")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(path.levels) { level in
                                LevelButton(
                                    level: level,
                                    isSelected: currentLevel?.id == level.id,
                                    color: path.color
                                ) {
                                    currentLevel = level
                                    // Auto-select next level as target
                                    if let index = path.levels.firstIndex(where: { $0.id == level.id }),
                                       index + 1 < path.levels.count {
                                        targetLevel = path.levels[index + 1]
                                    }
                                }
                            }
                        }
                    }
                }

                // Target Level
                if currentLevel != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Target Level")
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(path.levels.filter { $0.level > (currentLevel?.level ?? 0) }) { level in
                                    LevelButton(
                                        level: level,
                                        isSelected: targetLevel?.id == level.id,
                                        color: path.color
                                    ) {
                                        targetLevel = level
                                    }
                                }
                            }
                        }
                    }
                }

                // Show salary jump
                if let current = currentLevel, let target = targetLevel {
                    SalaryJumpView(currentLevel: current, targetLevel: target, color: path.color)
                }
            }
        }
    }
}

// MARK: - Career Path Button

struct CareerPathButton: View {
    let path: CareerPath
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: path.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : path.color)

                Text(path.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(1)
            }
            .padding()
            .background(isSelected ? path.color : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? path.color : Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Level Button

struct LevelButton: View {
    let level: CareerLevel
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(level.title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(1)

                Text("$\(level.salaryRange.lowerBound/1000)k-\(level.salaryRange.upperBound/1000)k")
                    .font(.caption2)
                    .foregroundStyle(isSelected ? .white.opacity(0.8) : Color.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? color : Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Salary Jump View

struct SalaryJumpView: View {
    let currentLevel: CareerLevel
    let targetLevel: CareerLevel
    let color: Color

    var salaryIncrease: Int {
        targetLevel.salaryRange.lowerBound - currentLevel.salaryRange.lowerBound
    }

    var body: some View {
        HStack {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text("Potential Salary Increase")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)

                Text("+$\(salaryIncrease/1000)k - $\((targetLevel.salaryRange.upperBound - currentLevel.salaryRange.upperBound)/1000)k")
                    .font(.headline)
                    .foregroundStyle(color)
            }

            Spacer()
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Fitness Sprint Form

struct FitnessSprintForm: View {
    @Binding var goal: String
    @Binding var currentWeight: Double
    @Binding var targetWeight: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Goal name
            VStack(alignment: .leading, spacing: 8) {
                Text("Goal Name")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                TextField("e.g., Summer Shred, Marathon Prep", text: $goal)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(Color.primaryText)
            }

            // Weight
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Current Weight")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Spacer()

                    Text("\(Int(currentWeight)) lbs")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.orange)
                }

                Slider(value: $currentWeight, in: 80...400, step: 1)
                    .tint(Color.orange)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Target Weight")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Spacer()

                    Text("\(Int(targetWeight)) lbs")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                }

                Slider(value: $targetWeight, in: 80...400, step: 1)
                    .tint(Color.green)
            }

            // Change display
            let change = targetWeight - currentWeight
            if abs(change) > 0 {
                HStack {
                    Image(systemName: change > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .foregroundStyle(change > 0 ? .green : .orange)

                    Text(change > 0 ? "Gain \(Int(change)) lbs" : "Lose \(Int(abs(change))) lbs")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Financial Sprint Form

struct FinancialSprintForm: View {
    @Binding var targetAmount: Double
    @Binding var purpose: String

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Purpose
            VStack(alignment: .leading, spacing: 8) {
                Text("Purpose")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                TextField("e.g., Emergency Fund, Vacation, Down Payment", text: $purpose)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(Color.primaryText)
            }

            // Target amount
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Target Amount")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Spacer()

                    Text("$\(Int(targetAmount))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.green)
                }

                Slider(value: $targetAmount, in: 100...50000, step: 100)
                    .tint(Color.green)

                // Quick select buttons
                HStack(spacing: 8) {
                    AmountButton(amount: 500, selected: targetAmount == 500) { targetAmount = 500 }
                    AmountButton(amount: 1000, selected: targetAmount == 1000) { targetAmount = 1000 }
                    AmountButton(amount: 5000, selected: targetAmount == 5000) { targetAmount = 5000 }
                    AmountButton(amount: 10000, selected: targetAmount == 10000) { targetAmount = 10000 }
                }
            }

            // Weekly savings needed (for 90 days = ~13 weeks)
            let weeklySavings = targetAmount / 13
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.green)

                Text("Save ~$\(Int(weeklySavings))/week to hit your goal")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.green.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct AmountButton: View {
    let amount: Double
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("$\(Int(amount))")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(selected ? .white : Color.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selected ? Color.green : Color.cardBackground)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Sprint Form

struct CustomSprintForm: View {
    @Binding var name: String
    @Binding var duration: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sprint Name")
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                TextField("What's your goal?", text: $name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .foregroundStyle(Color.primaryText)
            }
        }
    }
}

// MARK: - Sprint Detail View

struct SprintDetailView: View {
    let sprint: Sprint
    let onUpdate: (Sprint) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var editedSprint: Sprint

    init(sprint: Sprint, onUpdate: @escaping (Sprint) -> Void) {
        self.sprint = sprint
        self.onUpdate = onUpdate
        self._editedSprint = State(initialValue: sprint)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(sprint.color.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: sprint.icon)
                                .font(.system(size: 36))
                                .foregroundStyle(sprint.color)
                        }

                        Text(sprint.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.primaryText)
                            .multilineTextAlignment(.center)

                        Text(sprint.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding()

                    // Progress Overview
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(Int(sprint.progress * 100))%")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(sprint.color)

                                Text("Complete")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text("\(sprint.daysRemaining)")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundStyle(sprint.daysRemaining <= 7 ? .orange : Color.primaryText)

                                Text("Days Left")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }

                        // Big progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.borderColor)
                                    .frame(height: 12)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [sprint.color, sprint.color.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * sprint.progress, height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    // Metrics
                    if !sprint.targetMetrics.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Metrics")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)
                                .padding(.horizontal)

                            ForEach(editedSprint.targetMetrics.indices, id: \.self) { index in
                                MetricRow(
                                    metric: $editedSprint.targetMetrics[index],
                                    color: sprint.color
                                )
                            }
                        }
                    }

                    // Complete Sprint Button
                    if !sprint.isCompleted {
                        Button {
                            var updated = editedSprint
                            updated.isCompleted = true
                            updated.completedDate = Date()
                            onUpdate(updated)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Complete Sprint")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(sprint.color)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    }

                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
            .background(Color.gridBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondaryText)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onUpdate(editedSprint)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentGreen)
                }
            }
        }
    }
}

// MARK: - Metric Row

struct MetricRow: View {
    @Binding var metric: SprintMetric
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: metric.icon)
                    .foregroundStyle(color)

                Text(metric.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.primaryText)

                Spacer()

                Text("\(metric.displayValue) / \(Int(metric.targetValue)) \(metric.unit)")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            // Editable slider
            Slider(value: $metric.currentValue, in: 0...metric.targetValue)
                .tint(color)

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.borderColor)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: geometry.size.width * metric.progress, height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

#Preview {
    SprintDashboardView()
        .preferredColorScheme(.dark)
}
