import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName: String = ""
    @State private var selectedPath: LifePathCategory?
    @State private var selectedHabits: Set<UUID> = []
    @State private var showCustomPathSheet = false
    @State private var selectedPathsForHybrid: Set<LifePathCategory> = []
    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var notifications = NotificationManager.shared

    // Student-specific state
    @State private var selectedStudentType: StudentType?
    @State private var selectedMajor: StudentMajor?
    @State private var selectedCollege: CollegeInfo?
    @State private var currentGPA: Double = 3.5
    @State private var showCollegeSelector = false

    // Career-specific state
    @State private var selectedCareerPath: CareerPath?
    @State private var currentCareerLevel: CareerLevel?
    @State private var targetCareerLevel: CareerLevel?

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case nameInput
        case pathSelection
        case studentDetails   // New: for student path customization
        case careerDetails    // New: for professional path customization
        case habitSelection
        case sprintSetup      // New: set up first sprint/goal
        case permissions
        case motivation
        case ready

        var progress: Double {
            // Adjust progress calculation for dynamic steps
            let totalSteps = 8.0 // Approximate visible steps
            return min(1.0, Double(rawValue) / totalSteps)
        }
    }

    var body: some View {
        ZStack {
            // Dynamic background based on selected path
            backgroundGradient
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.5), value: selectedPath)

            VStack(spacing: 0) {
                // Progress bar
                if currentStep != .welcome {
                    progressBar
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                // Content
                Group {
                    switch currentStep {
                    case .welcome:
                        welcomeStep
                    case .nameInput:
                        nameStep
                    case .pathSelection:
                        pathSelectionStep
                    case .studentDetails:
                        studentDetailsStep
                    case .careerDetails:
                        careerDetailsStep
                    case .habitSelection:
                        habitSelectionStep
                    case .sprintSetup:
                        sprintSetupStep
                    case .permissions:
                        permissionsStep
                    case .motivation:
                        motivationStep
                    case .ready:
                        readyStep
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        Group {
            if let path = selectedPath {
                LinearGradient(
                    colors: [path.color.opacity(0.15), Color.gridBackground, Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                LinearGradient(
                    colors: [Color.gridBackground, Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.borderColor)
                    .frame(height: 6)

                RoundedRectangle(cornerRadius: 4)
                    .fill(selectedPath?.color ?? Color.accentGreen)
                    .frame(width: geometry.size.width * currentStep.progress, height: 6)
                    .animation(.spring(), value: currentStep)
            }
        }
        .frame(height: 6)
    }

    // MARK: - Welcome Step

    private var welcomeStep: some View {
        VStack(spacing: 40) {
            Spacer()

            // Animated logo
            ZStack {
                // Outer glow
                Circle()
                    .fill(Color.accentGreen.opacity(0.3))
                    .frame(width: 140, height: 140)
                    .blur(radius: 20)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentGreen, Color.accentGreen.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 16) {
                Text("Welcome to Blocks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Build the life you want,\none day at a time.")
                    .font(.title3)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Social proof
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                Text("Join thousands building better habits")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()

            // Value propositions
            VStack(spacing: 12) {
                ValuePropRow(icon: "chart.line.uptrend.xyaxis", text: "Visual progress tracking")
                ValuePropRow(icon: "bell.badge.fill", text: "Smart reminders")
                ValuePropRow(icon: "person.2.fill", text: "Community challenges")
            }
            .padding(.horizontal, 40)

            // CTA Button
            Button {
                HapticManager.shared.mediumTap()
                withAnimation { currentStep = .nameInput }
            } label: {
                HStack {
                    Text("Start Building Your Path")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Color.accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)

            Text("Identify your path,build your future.")
                .font(.caption)
                .foregroundStyle(Color.secondaryText)
                .padding(.bottom, 40)
        }
    }

    // MARK: - Name Step

    private var nameStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentGreen)

                Text("What should we call you?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Let's make this personal.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }

            ZStack {
                if userName.isEmpty {
                    Text("Your first name")
                        .font(.title2)
                        .foregroundStyle(Color.placeholderText)
                }
                TextField("", text: $userName)
                    .font(.title2)
                    .foregroundStyle(Color.inputText)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color.cardBackgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.borderColor, lineWidth: 1)
            )
            .padding(.horizontal, 40)

            Spacer()

            navigationButtons(
                backStep: .welcome,
                nextStep: .pathSelection,
                canContinue: !userName.trimmingCharacters(in: .whitespaces).isEmpty
            )
        }
    }

    // MARK: - Path Selection Step

    private var pathSelectionStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("What's your vision, \(userName)?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Choose your path to greatness")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                        ForEach(LifePathCategory.allCases.filter { $0 != .custom && $0 != .exploring }, id: \.self) { path in
                            PathCard(
                                path: path,
                                isSelected: selectedPath == path
                            ) {
                                HapticManager.shared.lightTap()
                                withAnimation(.spring(response: 0.3)) {
                                    selectedPath = path
                                    // Pre-select all habits by default
                                    selectedHabits = Set(path.suggestedHabits.map { $0.id })
                                }
                            }
                        }
                    }

                    // Custom/Hybrid Path Option
                    CustomPathCard(
                        isPremium: AppSettings.shared.isPremium,
                        onTap: {
                            if AppSettings.shared.isPremium {
                                showCustomPathSheet = true
                            }
                        }
                    )
                    .padding(.top, 4)

                    // Skip option - just build habits without a path
                    SkipPathCard {
                        HapticManager.shared.lightTap()
                        // Skip to habit selection with generic habits
                        AppSettings.shared.isExplorationMode = true
                        withAnimation { currentStep = .habitSelection }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }

            navigationButtons(
                backStep: .nameInput,
                nextStep: nextStepAfterPathSelection,
                canContinue: selectedPath != nil
            )
        }
        .sheet(isPresented: $showCustomPathSheet) {
            CustomPathBuilderSheet(
                selectedPaths: $selectedPathsForHybrid,
                onSave: { paths in
                    // Combine habits from selected paths
                    var combinedHabits: [HabitTemplate] = []
                    for path in paths {
                        combinedHabits.append(contentsOf: path.suggestedHabits)
                    }
                    // Remove duplicates and limit
                    let uniqueHabits = Array(Set(combinedHabits.map { $0.id }))
                    selectedHabits = Set(uniqueHabits.prefix(10))
                    selectedPath = .custom
                    showCustomPathSheet = false
                }
            )
        }
    }

    // Helper to determine next step based on path selection
    private var nextStepAfterPathSelection: OnboardingStep {
        guard let path = selectedPath else { return .habitSelection }
        switch path {
        case .student:
            return .studentDetails
        case .entrepreneur, .softwareEngineer, .investor:
            return .careerDetails
        default:
            return .habitSelection
        }
    }

    // MARK: - Student Details Step

    private var studentDetailsStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Tell us about your studies")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("We'll customize your path for academic success")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Student Type
                    VStack(alignment: .leading, spacing: 12) {
                        Text("I am a...")
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(StudentType.allCases, id: \.self) { type in
                                StudentTypeCard(
                                    type: type,
                                    isSelected: selectedStudentType == type
                                ) {
                                    HapticManager.shared.lightTap()
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedStudentType = type
                                    }
                                }
                            }
                        }
                    }

                    // Major/Focus (for high school show intended major)
                    if selectedStudentType != nil {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(selectedStudentType == .highSchool ? "Intended Major" : "Major/Focus")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(StudentMajor.allCases.prefix(12), id: \.self) { major in
                                    MajorCard(
                                        major: major,
                                        isSelected: selectedMajor == major
                                    ) {
                                        HapticManager.shared.lightTap()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedMajor = major
                                            // Add major-specific habits
                                            for habit in major.suggestedHabits {
                                                selectedHabits.insert(habit.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // College Target (for high school students)
                    if selectedStudentType == .highSchool {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Dream School (Optional)")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)

                            Button {
                                showCollegeSelector = true
                            } label: {
                                HStack {
                                    if let college = selectedCollege {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(college.shortName)
                                                .font(.headline)
                                                .foregroundStyle(Color.primaryText)

                                            Text("\(college.gpaDescription) • \(Int(college.acceptanceRate))% acceptance")
                                                .font(.caption)
                                                .foregroundStyle(Color.secondaryText)
                                        }
                                    } else {
                                        HStack {
                                            Image(systemName: "graduationcap")
                                                .foregroundStyle(Color.secondaryText)
                                            Text("Select a target college...")
                                                .foregroundStyle(Color.secondaryText)
                                        }
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

                            // GPA Input if college selected
                            if selectedCollege != nil {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Current GPA")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.primaryText)

                                        Spacer()

                                        Text(String(format: "%.2f", currentGPA))
                                            .font(.headline)
                                            .foregroundStyle(Color.accentGreen)
                                    }

                                    Slider(value: $currentGPA, in: 1.0...4.3, step: 0.01)
                                        .tint(Color.accentGreen)
                                }
                                .padding()
                                .background(Color.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            navigationButtons(
                backStep: .pathSelection,
                nextStep: .habitSelection,
                canContinue: selectedStudentType != nil
            )
        }
        .sheet(isPresented: $showCollegeSelector) {
            CollegeSearchView(selectedCollege: $selectedCollege)
        }
    }

    // MARK: - Career Details Step

    private var careerDetailsStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Where are you headed?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Set your career trajectory")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Career Path Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Career Track")
                            .font(.headline)
                            .foregroundStyle(Color.primaryText)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(CareerDatabase.paths) { path in
                                    CareerPathCard(
                                        path: path,
                                        isSelected: selectedCareerPath?.id == path.id
                                    ) {
                                        HapticManager.shared.lightTap()
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedCareerPath = path
                                            currentCareerLevel = nil
                                            targetCareerLevel = nil
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Current Level
                    if let path = selectedCareerPath {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Current Level")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)

                            ForEach(path.levels) { level in
                                CareerLevelRow(
                                    level: level,
                                    isSelected: currentCareerLevel?.id == level.id,
                                    color: path.color
                                ) {
                                    HapticManager.shared.lightTap()
                                    withAnimation(.spring(response: 0.3)) {
                                        currentCareerLevel = level
                                        // Auto-select next level as target
                                        if let index = path.levels.firstIndex(where: { $0.id == level.id }),
                                           index + 1 < path.levels.count {
                                            targetCareerLevel = path.levels[index + 1]
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Target Level
                    if let path = selectedCareerPath, let current = currentCareerLevel {
                        let availableLevels = path.levels.filter { $0.level > current.level }
                        if !availableLevels.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Target Level")
                                    .font(.headline)
                                    .foregroundStyle(Color.primaryText)

                                ForEach(availableLevels) { level in
                                    CareerLevelRow(
                                        level: level,
                                        isSelected: targetCareerLevel?.id == level.id,
                                        color: path.color
                                    ) {
                                        HapticManager.shared.lightTap()
                                        withAnimation(.spring(response: 0.3)) {
                                            targetCareerLevel = level
                                            // Add level-specific habits
                                            for habit in level.habits {
                                                selectedHabits.insert(habit.id)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Salary Jump Preview
                    if let path = selectedCareerPath, let current = currentCareerLevel, let target = targetCareerLevel {
                        SalaryJumpView(currentLevel: current, targetLevel: target, color: path.color)
                    }
                }
                .padding(.horizontal)
            }

            navigationButtons(
                backStep: .pathSelection,
                nextStep: .habitSelection,
                canContinue: selectedCareerPath != nil && currentCareerLevel != nil
            )
        }
    }

    // MARK: - Sprint Setup Step

    private var sprintSetupStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Image(systemName: "bolt.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Set Your First Sprint")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Sprints are focused short-term goals that accelerate your progress")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 24)

            // Show relevant sprint suggestion based on path
            VStack(spacing: 16) {
                if selectedPath == .student, let college = selectedCollege {
                    // College admission sprint suggestion
                    SprintSuggestionCard(
                        title: "Get into \(college.shortName)",
                        description: "Track GPA, test scores, and activities to maximize your admission chances",
                        icon: "graduationcap.fill",
                        color: .blue
                    )
                } else if let target = targetCareerLevel {
                    // Career advancement sprint suggestion
                    SprintSuggestionCard(
                        title: "Reach \(target.title)",
                        description: "Build skills and visibility to accelerate your promotion",
                        icon: "arrow.up.circle.fill",
                        color: .purple
                    )
                } else {
                    // Generic sprint suggestion
                    SprintSuggestionCard(
                        title: "30-Day Kickstart",
                        description: "Build momentum with a focused 30-day sprint on your path",
                        icon: "flame.fill",
                        color: .orange
                    )
                }

                Text("You can set up sprints anytime from the main screen")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.horizontal)

            Spacer()

            navigationButtons(
                backStep: .habitSelection,
                nextStep: .permissions,
                canContinue: true,
                nextButtonText: "Continue"
            )
        }
    }

    // MARK: - Habit Selection Step

    private var habitSelectionStep: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Your Daily Actions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text(AppSettings.shared.isExplorationMode
                    ? "Start with foundational habits"
                    : "These habits will move you toward your goals")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.top, 24)

            // Exploration mode - show generic habits
            if AppSettings.shared.isExplorationMode {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(ExplorationHabits.habits) { habit in
                            HabitTemplateRow(
                                template: habit,
                                isSelected: selectedHabits.contains(habit.id)
                            ) {
                                HapticManager.shared.lightTap()
                                withAnimation(.spring(response: 0.2)) {
                                    if selectedHabits.contains(habit.id) {
                                        selectedHabits.remove(habit.id)
                                    } else {
                                        selectedHabits.insert(habit.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Selection count
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentGreen)
                    Text("\(selectedHabits.count) habits selected")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 8)

                Text("You can always add path-specific habits later")
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
            } else if let path = selectedPath {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        // Path-specific habits
                        ForEach(path.suggestedHabits) { habit in
                            HabitTemplateRow(
                                template: habit,
                                isSelected: selectedHabits.contains(habit.id)
                            ) {
                                HapticManager.shared.lightTap()
                                withAnimation(.spring(response: 0.2)) {
                                    if selectedHabits.contains(habit.id) {
                                        selectedHabits.remove(habit.id)
                                    } else {
                                        selectedHabits.insert(habit.id)
                                    }
                                }
                            }
                        }

                        // Major-specific habits (for students)
                        if let major = selectedMajor, !major.suggestedHabits.isEmpty {
                            Text("\(major.displayName) Focus")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)

                            ForEach(major.suggestedHabits) { habit in
                                HabitTemplateRow(
                                    template: habit,
                                    isSelected: selectedHabits.contains(habit.id)
                                ) {
                                    HapticManager.shared.lightTap()
                                    withAnimation(.spring(response: 0.2)) {
                                        if selectedHabits.contains(habit.id) {
                                            selectedHabits.remove(habit.id)
                                        } else {
                                            selectedHabits.insert(habit.id)
                                        }
                                    }
                                }
                            }
                        }

                        // Career level habits
                        if let targetLevel = targetCareerLevel, !targetLevel.habits.isEmpty {
                            Text("\(targetLevel.title) Skills")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)

                            ForEach(targetLevel.habits) { habit in
                                HabitTemplateRow(
                                    template: habit,
                                    isSelected: selectedHabits.contains(habit.id)
                                ) {
                                    HapticManager.shared.lightTap()
                                    withAnimation(.spring(response: 0.2)) {
                                        if selectedHabits.contains(habit.id) {
                                            selectedHabits.remove(habit.id)
                                        } else {
                                            selectedHabits.insert(habit.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Selection count
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentGreen)
                    Text("\(selectedHabits.count) habits selected")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(.vertical, 8)
            }

            navigationButtons(
                backStep: previousStepForHabitSelection,
                nextStep: .sprintSetup,
                canContinue: !selectedHabits.isEmpty
            )
        }
    }

    // MARK: - Permissions Step

    private var permissionsStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)

                Text("Stay on Track")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                Text("Enable notifications to get daily reminders and stay motivated on your journey.")
                    .font(.body)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Permission toggles
            VStack(spacing: 16) {
                PermissionRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Daily check-in reminders",
                    isEnabled: notifications.isAuthorized
                ) {
                    Task {
                        _ = await notifications.requestAuthorization()
                    }
                }

                if healthKit.isHealthKitAvailable {
                    PermissionRow(
                        icon: "heart.fill",
                        title: "Apple Health",
                        description: "Auto-track exercise & sleep",
                        isEnabled: healthKit.isAuthorized
                    ) {
                        Task {
                            _ = await healthKit.requestAuthorization()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            navigationButtons(
                backStep: .sprintSetup,
                nextStep: .motivation,
                canContinue: true,
                nextButtonText: "Continue"
            )
        }
    }

    // Helper to determine previous step for habit selection
    private var previousStepForHabitSelection: OnboardingStep {
        // If in exploration mode, go back to path selection
        if AppSettings.shared.isExplorationMode {
            return .pathSelection
        }
        guard let path = selectedPath else { return .pathSelection }
        switch path {
        case .student:
            return .studentDetails
        case .entrepreneur, .softwareEngineer, .investor:
            return .careerDetails
        default:
            return .pathSelection
        }
    }

    // MARK: - Motivation Step

    private var motivationStep: some View {
        VStack(spacing: 32) {
            Spacer()

            if AppSettings.shared.isExplorationMode {
                // Exploration mode motivation
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.accentGreen.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .blur(radius: 15)

                        Circle()
                            .fill(Color.accentGreen.opacity(0.2))
                            .frame(width: 80, height: 80)

                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.accentGreen)
                    }

                    Text("Your Journey of Discovery")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryText)

                    Text("Build habits, find your path")
                        .font(.title3)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 8) {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(Color.accentGreen.opacity(0.5))

                        Text("The journey of a thousand miles begins with a single step.")
                            .font(.body)
                            .italic()
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.top, 16)
                }
            } else if let path = selectedPath {
                VStack(spacing: 24) {
                    // Path icon with glow
                    ZStack {
                        Circle()
                            .fill(path.color.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .blur(radius: 15)

                        Circle()
                            .fill(path.color.opacity(0.2))
                            .frame(width: 80, height: 80)

                        Image(systemName: path.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(path.color)
                    }

                    Text("Your \(path.displayName) Journey")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryText)

                    Text(path.tagline)
                        .font(.title3)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    // Motivational quote
                    if let quote = path.motivationalQuotes.randomElement() {
                        VStack(spacing: 8) {
                            Image(systemName: "quote.opening")
                                .foregroundStyle(path.color.opacity(0.5))

                            Text(quote)
                                .font(.body)
                                .italic()
                                .foregroundStyle(Color.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 16)
                    }
                }
            }

            Spacer()

            navigationButtons(
                backStep: .permissions,
                nextStep: .ready,
                canContinue: true
            )
        }
    }

    // MARK: - Ready Step

    private var readyStep: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 24) {
                // Success animation
                ZStack {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.accentGreen)
                }

                Text("You're Ready, \(userName)!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primaryText)

                VStack(spacing: 12) {
                    if AppSettings.shared.isExplorationMode {
                        summaryRow(icon: "sparkles", text: "Explorer Mode", color: .accentGreen)
                    } else {
                        summaryRow(icon: selectedPath?.icon ?? "star.fill", text: selectedPath?.displayName ?? "Custom Path", color: selectedPath?.color ?? .gray)
                    }
                    summaryRow(icon: "checkmark.circle.fill", text: "\(selectedHabits.count) daily habits", color: .green)
                    summaryRow(icon: "calendar", text: "Day 1 starts now", color: .blue)
                }
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

                Text("Every journey begins with a single step.\nYours starts today.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
                HapticManager.shared.success()
                completeOnboarding()
            } label: {
                HStack {
                    Text("Begin My Journey")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [selectedPath?.color ?? Color.accentGreen, (selectedPath?.color ?? Color.accentGreen).opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func summaryRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.primaryText)
            Spacer()
        }
    }

    // MARK: - Navigation Buttons

    private func navigationButtons(
        backStep: OnboardingStep?,
        nextStep: OnboardingStep,
        canContinue: Bool,
        nextButtonText: String = "Continue"
    ) -> some View {
        HStack(spacing: 16) {
            if let back = backStep, currentStep.rawValue > 0 {
                Button {
                    withAnimation { currentStep = back }
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                        .frame(width: 56, height: 56)
                        .background(Color.cardBackground)
                        .clipShape(Circle())
                }
            }

            Button {
                withAnimation { currentStep = nextStep }
            } label: {
                HStack {
                    Text(nextButtonText)
                        .font(.headline)
                    if canContinue {
                        Image(systemName: "arrow.right")
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(canContinue ? (selectedPath?.color ?? Color.accentGreen) : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!canContinue)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }

    // MARK: - Complete Onboarding

    private func completeOnboarding() {
        // Handle exploration mode - no path selected
        if AppSettings.shared.isExplorationMode {
            // Create habits from exploration templates
            let templates = ExplorationHabits.habits.filter { selectedHabits.contains($0.id) }
            for (index, template) in templates.enumerated() {
                let habit = Habit(
                    name: template.name,
                    icon: template.icon,
                    colorHex: template.color
                )
                habit.sortOrder = index
                modelContext.insert(habit)
            }
        } else {
            guard let path = selectedPath else { return }

            // Save life path
            let lifePath = UserLifePath(path: path)
            AppSettings.shared.userLifePath = lifePath
            AppSettings.shared.pathStartDate = Date()

            // Create habits from selected templates
            let templates = path.suggestedHabits.filter { selectedHabits.contains($0.id) }
            for (index, template) in templates.enumerated() {
                let habit = Habit(
                    name: template.name,
                    icon: template.icon,
                    colorHex: template.color
                )
                habit.sortOrder = index
                modelContext.insert(habit)
            }
        }

        // Create user settings
        let settings = UserSettings()
        modelContext.insert(settings)

        try? modelContext.save()

        // Schedule notifications if authorized
        if notifications.isAuthorized {
            Task {
                await notifications.scheduleDailyReminder(at: settings.reminderTime)
                await notifications.scheduleMorningMotivation()
            }
        }

        // Mark onboarding complete
        AppSettings.shared.hasCompletedOnboarding = true
        AppSettings.shared.isOnboardingComplete = true

        withAnimation {
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Path Card

struct PathCard: View {
    let path: LifePathCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: path.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? .white : path.color)

                Text(path.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? path.color : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(isSelected ? path.color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Habit Template Row

struct HabitTemplateRow: View {
    let template: HabitTemplate
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color(hex: template.color).opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: template.icon)
                        .font(.title3)
                        .foregroundStyle(Color(hex: template.color))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(template.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primaryText)

                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentGreen : Color.tertiaryText)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentGreen.opacity(0.08) : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.accentGreen.opacity(0.5) : Color.borderColor.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Permission Row

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isEnabled ? Color.accentGreen : Color.secondaryText)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentGreen)
                } else {
                    Text("Enable")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentGreen)
                        .clipShape(Capsule())
                }
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(isEnabled)
    }
}

// MARK: - Value Proposition Row

struct ValuePropRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.accentGreen)
                .frame(width: 24)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.primaryText)

            Spacer()

            Image(systemName: "checkmark")
                .font(.caption)
                .foregroundStyle(Color.accentGreen)
        }
    }
}

// MARK: - Skip Path Card

struct SkipPathCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.secondaryText.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "sparkle")
                        .font(.title2)
                        .foregroundStyle(Color.secondaryText)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("I'm Still Exploring")
                        .font(.headline)
                        .foregroundStyle(Color.primaryText)

                    Text("Build habits first, choose a path later")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(Color.tertiaryText)
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Path Card

struct CustomPathCard: View {
    let isPremium: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Icon stack showing multiple paths
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue, .green],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Create Your Own Path")
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)

                            if !isPremium {
                                Text("PRO")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
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

                        Text(isPremium ? "Combine multiple paths into one" : "Mix habits from multiple paths")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.body)
                        .foregroundStyle(Color.tertiaryText)
                }

                if !isPremium {
                    // Teaser for free users
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)

                        Text("New paths added weekly! Upgrade to create custom combinations.")
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)

                        Spacer()
                    }
                    .padding(10)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        LinearGradient(
                            colors: isPremium ? [.purple, .blue, .green] : [Color.borderColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isPremium ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Path Builder Sheet

struct CustomPathBuilderSheet: View {
    @Binding var selectedPaths: Set<LifePathCategory>
    let onSave: (Set<LifePathCategory>) -> Void
    @Environment(\.dismiss) private var dismiss

    private let availablePaths = LifePathCategory.allCases.filter { $0 != .custom && $0 != .exploring }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .blue, .green],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Build Your Hybrid Path")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryText)

                    Text("Select 2-3 paths to combine their habits")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.top)

                // Selection count
                HStack {
                    Text("\(selectedPaths.count) of 3 selected")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)

                    Spacer()

                    if selectedPaths.count > 0 {
                        Button("Clear All") {
                            selectedPaths.removeAll()
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                }
                .padding(.horizontal)

                // Path grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(availablePaths, id: \.self) { path in
                            HybridPathOption(
                                path: path,
                                isSelected: selectedPaths.contains(path),
                                isDisabled: selectedPaths.count >= 3 && !selectedPaths.contains(path)
                            ) {
                                if selectedPaths.contains(path) {
                                    selectedPaths.remove(path)
                                } else if selectedPaths.count < 3 {
                                    selectedPaths.insert(path)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Save button
                Button {
                    onSave(selectedPaths)
                } label: {
                    Text("Create Hybrid Path")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            selectedPaths.count >= 2
                                ? LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
                                : LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedPaths.count < 2)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.gridBackground)
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

// MARK: - Hybrid Path Option

struct HybridPathOption: View {
    let path: LifePathCategory
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? path.color : path.color.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: path.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? .white : path.color)
                }

                Text(path.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isDisabled ? Color.tertiaryText : Color.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? path.color.opacity(0.15) : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? path.color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
            .opacity(isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - Student Type Card

struct StudentTypeCard: View {
    let type: StudentType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .cyan)

                Text(type.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.cyan : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? Color.cyan : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Major Card

struct MajorCard: View {
    let major: StudentMajor
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: major.icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : .blue)

                Text(major.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.blue : Color.borderColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Career Path Card

struct CareerPathCard: View {
    let path: CareerPath
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: path.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : path.color)

                Text(path.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100)
            .padding(.vertical, 16)
            .background(isSelected ? path.color : Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? path.color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Career Level Row

struct CareerLevelRow: View {
    let level: CareerLevel
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Level indicator
                ZStack {
                    Circle()
                        .fill(isSelected ? color : color.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Text("\(level.level)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? .white : color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primaryText)

                    Text("$\(level.salaryRange.lowerBound/1000)k - $\(level.salaryRange.upperBound/1000)k")
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? color : Color.tertiaryText)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.1) : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isSelected ? color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sprint Suggestion Card

struct SprintSuggestionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.primaryText)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.tertiaryText)
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [Habit.self, UserSettings.self], inMemory: true)
        .preferredColorScheme(.dark)
}
