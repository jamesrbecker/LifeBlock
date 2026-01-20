import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var hasCompletedOnboarding: Bool

    @State private var currentStep: OnboardingStep = .welcome
    @State private var userName: String = ""
    @State private var selectedPath: LifePathCategory?
    @State private var selectedHabits: Set<UUID> = []
    @StateObject private var healthKit = HealthKitManager.shared
    @StateObject private var notifications = NotificationManager.shared

    enum OnboardingStep: Int, CaseIterable {
        case welcome
        case nameInput
        case pathSelection
        case habitSelection
        case permissions
        case motivation
        case ready

        var progress: Double {
            Double(rawValue) / Double(Self.allCases.count - 1)
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
                    case .habitSelection:
                        habitSelectionStep
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
                Text("Welcome to LifeBlocks")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Build the life you want,\none day at a time.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
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
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // CTA Button
            Button {
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

            Text("Takes only 60 seconds")
                .font(.caption)
                .foregroundStyle(.secondary)
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

                Text("Let's make this personal.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("Your first name", text: $userName)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.cardBackground)
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

                Text("Choose your path to greatness")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)

            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(LifePathCategory.allCases.filter { $0 != .custom }, id: \.self) { path in
                        PathCard(
                            path: path,
                            isSelected: selectedPath == path
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedPath = path
                                // Pre-select all habits by default
                                selectedHabits = Set(path.suggestedHabits.map { $0.id })
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            navigationButtons(
                backStep: .nameInput,
                nextStep: .habitSelection,
                canContinue: selectedPath != nil
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

                Text("These habits will move you toward your goals")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)

            if let path = selectedPath {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(path.suggestedHabits) { habit in
                            HabitTemplateRow(
                                template: habit,
                                isSelected: selectedHabits.contains(habit.id)
                            ) {
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
            }

            navigationButtons(
                backStep: .pathSelection,
                nextStep: .permissions,
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

                Text("Enable notifications to get daily reminders and stay motivated on your journey.")
                    .font(.body)
                    .foregroundStyle(.secondary)
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
                backStep: .habitSelection,
                nextStep: .motivation,
                canContinue: true,
                nextButtonText: "Continue"
            )
        }
    }

    // MARK: - Motivation Step

    private var motivationStep: some View {
        VStack(spacing: 32) {
            Spacer()

            if let path = selectedPath {
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

                    Text(path.tagline)
                        .font(.title3)
                        .foregroundStyle(.secondary)
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
                                .foregroundStyle(.secondary)
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

                VStack(spacing: 12) {
                    summaryRow(icon: selectedPath?.icon ?? "star.fill", text: selectedPath?.displayName ?? "Custom Path", color: selectedPath?.color ?? .gray)
                    summaryRow(icon: "checkmark.circle.fill", text: "\(selectedHabits.count) daily habits", color: .green)
                    summaryRow(icon: "calendar", text: "Day 1 starts now", color: .blue)
                }
                .padding()
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 24)

                Text("Every journey begins with a single step.\nYours starts today.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            Button {
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
                        .foregroundStyle(.secondary)
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
                    .foregroundStyle(isSelected ? .white : .primary)
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
                        .foregroundStyle(.primary)

                    Text(template.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.accentGreen : .secondary.opacity(0.5))
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
                    .foregroundStyle(isEnabled ? .green : .secondary)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isEnabled {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
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

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
        .modelContainer(for: [Habit.self, UserSettings.self], inMemory: true)
        .preferredColorScheme(.dark)
}
