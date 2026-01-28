import SwiftUI
import SwiftData

// MARK: - Habit Template Library View

struct HabitTemplateLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Habit.sortOrder) private var existingHabits: [Habit]
    @ObservedObject private var subscription = SubscriptionStatus.shared

    @State private var searchText = ""
    @State private var selectedCategory: TemplateCategory?
    @State private var addedTemplates: Set<String> = []

    private var customHabitCount: Int {
        existingHabits.filter { !$0.isSystemHabit }.count
    }

    private var canAddHabit: Bool {
        subscription.canAddMoreHabits(currentCount: customHabitCount + addedTemplates.count)
    }

    var body: some View {
        NavigationStack {
            List {
                if selectedCategory == nil {
                    // Category browsing mode
                    categoryListView
                } else {
                    // Template list for selected category
                    templateListView
                }
            }
            .searchable(text: $searchText, prompt: "Search habits...")
            .navigationTitle(selectedCategory?.displayName ?? "Habit Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if selectedCategory != nil {
                        Button {
                            withAnimation {
                                selectedCategory = nil
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Categories")
                            }
                        }
                    } else {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }

                if selectedCategory != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Category List

    private var categoryListView: some View {
        Group {
            if !searchText.isEmpty {
                // Show search results across all categories
                searchResultsSection
            } else {
                // Featured section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Browse Templates", systemImage: "rectangle.grid.2x2.fill")
                            .font(.headline)
                            .foregroundStyle(Color.accentGreen)

                        Text("Choose from \(totalTemplateCount) habit templates across \(TemplateCategory.allBrowsable.count) categories. Add any template to your habits with one tap.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }
                    .padding(.vertical, 4)
                }

                // Foundational habits (free)
                Section("Foundational") {
                    CategoryRow(
                        category: .foundational,
                        isSelected: false
                    ) {
                        withAnimation {
                            selectedCategory = .foundational
                        }
                    }
                }

                // Path-based categories grouped
                Section("Creative & Media") {
                    ForEach(TemplateCategory.creativeMedia, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Tech & Engineering") {
                    ForEach(TemplateCategory.techEngineering, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Business & Finance") {
                    ForEach(TemplateCategory.businessFinance, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Healthcare") {
                    ForEach(TemplateCategory.healthcare, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Skilled Trades") {
                    ForEach(TemplateCategory.skilledTrades, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Professional & Public Service") {
                    ForEach(TemplateCategory.professional, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }

                Section("Lifestyle") {
                    ForEach(TemplateCategory.lifestyle, id: \.self) { cat in
                        CategoryRow(category: cat, isSelected: false) {
                            withAnimation { selectedCategory = cat }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Search Results

    private var searchResultsSection: some View {
        let results = allSearchResults
        return Group {
            if results.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundStyle(Color.secondaryText)
                        Text("No habits matching \"\(searchText)\"")
                            .foregroundStyle(Color.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            } else {
                Section("Results (\(results.count))") {
                    ForEach(results, id: \.template.id) { result in
                        TemplateRow(
                            template: result.template,
                            categoryName: result.categoryName,
                            isAlreadyAdded: isTemplateAdded(result.template),
                            canAdd: canAddHabit,
                            isPremium: subscription.isPremium
                        ) {
                            addTemplate(result.template)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Template List for Category

    private var templateListView: some View {
        Group {
            if let category = selectedCategory {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 10) {
                            Image(systemName: category.icon)
                                .font(.title2)
                                .foregroundStyle(category.color)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.displayName)
                                    .font(.headline)
                                Text(category.tagline)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                let templates = filteredTemplates(for: category)
                Section("\(templates.count) Habits") {
                    ForEach(templates, id: \.id) { template in
                        TemplateRow(
                            template: template,
                            categoryName: nil,
                            isAlreadyAdded: isTemplateAdded(template),
                            canAdd: canAddHabit,
                            isPremium: subscription.isPremium
                        ) {
                            addTemplate(template)
                        }
                    }
                }

                if !subscription.isPremium && customHabitCount + addedTemplates.count >= SubscriptionTier.free.maxCustomHabits {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Free habit limit reached")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Upgrade to Premium for unlimited habits")
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var totalTemplateCount: Int {
        TemplateCategory.allBrowsable.reduce(0) { $0 + $1.templates.count }
    }

    private func filteredTemplates(for category: TemplateCategory) -> [HabitTemplate] {
        if searchText.isEmpty {
            return category.templates
        }
        return category.templates.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var allSearchResults: [(template: HabitTemplate, categoryName: String)] {
        var results: [(template: HabitTemplate, categoryName: String)] = []
        for category in TemplateCategory.allBrowsable {
            for template in category.templates {
                if template.name.localizedCaseInsensitiveContains(searchText) ||
                   template.description.localizedCaseInsensitiveContains(searchText) {
                    results.append((template: template, categoryName: category.displayName))
                }
            }
        }
        return results
    }

    private func isTemplateAdded(_ template: HabitTemplate) -> Bool {
        // Check if already in addedTemplates this session
        if addedTemplates.contains(template.id) { return true }
        // Check if a habit with this name already exists
        return existingHabits.contains { $0.name == template.name }
    }

    private func addTemplate(_ template: HabitTemplate) {
        let habit = template.toHabit()
        habit.sortOrder = existingHabits.count
        modelContext.insert(habit)
        try? modelContext.save()
        addedTemplates.insert(template.id)
    }
}

// MARK: - Template Category

enum TemplateCategory: String, CaseIterable, Hashable {
    case foundational
    case contentCreator, fitnessInfluencer, musician, actor, writer, creative
    case softwareEngineer, gameDeveloper
    case entrepreneur, investor, sales, realEstate
    case doctor, nurse, emt, physicalTherapist, dentalPro, healthWellness
    case electrician, plumber, welder, construction, hvacTech, carpenter, mechanic, truckDriver
    case teacher, lawyer, chef, pilot, military, firstResponder
    case student, athlete, parent, digitalNomad

    var displayName: String {
        switch self {
        case .foundational: return "Foundational Habits"
        default:
            return lifePath?.displayName ?? rawValue.capitalized
        }
    }

    var icon: String {
        switch self {
        case .foundational: return "sparkles"
        default:
            return lifePath?.icon ?? "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .foundational: return .green
        default:
            return lifePath?.color ?? .gray
        }
    }

    var tagline: String {
        switch self {
        case .foundational: return "Universal habits for everyone"
        default:
            return lifePath?.tagline ?? ""
        }
    }

    var templates: [HabitTemplate] {
        switch self {
        case .foundational: return ExplorationHabits.habits
        default:
            return lifePath?.suggestedHabits ?? []
        }
    }

    private var lifePath: LifePathCategory? {
        switch self {
        case .foundational: return nil
        case .contentCreator: return .contentCreator
        case .fitnessInfluencer: return .fitnessInfluencer
        case .musician: return .musician
        case .actor: return .actor
        case .writer: return .writer
        case .creative: return .creative
        case .softwareEngineer: return .softwareEngineer
        case .gameDeveloper: return .gameDeveloper
        case .entrepreneur: return .entrepreneur
        case .investor: return .investor
        case .sales: return .sales
        case .realEstate: return .realEstate
        case .doctor: return .doctor
        case .nurse: return .nurse
        case .emt: return .emt
        case .physicalTherapist: return .physicalTherapist
        case .dentalPro: return .dentalPro
        case .healthWellness: return .healthWellness
        case .electrician: return .electrician
        case .plumber: return .plumber
        case .welder: return .welder
        case .construction: return .construction
        case .hvacTech: return .hvacTech
        case .carpenter: return .carpenter
        case .mechanic: return .mechanic
        case .truckDriver: return .truckDriver
        case .teacher: return .teacher
        case .lawyer: return .lawyer
        case .chef: return .chef
        case .pilot: return .pilot
        case .military: return .military
        case .firstResponder: return .firstResponder
        case .student: return .student
        case .athlete: return .athlete
        case .parent: return .parent
        case .digitalNomad: return .digitalNomad
        }
    }

    // MARK: - Grouped Categories

    static let creativeMedia: [TemplateCategory] = [.contentCreator, .fitnessInfluencer, .musician, .actor, .writer, .creative]
    static let techEngineering: [TemplateCategory] = [.softwareEngineer, .gameDeveloper]
    static let businessFinance: [TemplateCategory] = [.entrepreneur, .investor, .sales, .realEstate]
    static let healthcare: [TemplateCategory] = [.doctor, .nurse, .emt, .physicalTherapist, .dentalPro, .healthWellness]
    static let skilledTrades: [TemplateCategory] = [.electrician, .plumber, .welder, .construction, .hvacTech, .carpenter, .mechanic, .truckDriver]
    static let professional: [TemplateCategory] = [.teacher, .lawyer, .chef, .pilot, .military, .firstResponder]
    static let lifestyle: [TemplateCategory] = [.student, .athlete, .parent, .digitalNomad]

    static let allBrowsable: [TemplateCategory] = [.foundational] + creativeMedia + techEngineering + businessFinance + healthcare + skilledTrades + professional + lifestyle
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: TemplateCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(category.color)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.displayName)
                        .font(.body)
                        .foregroundStyle(.primary)
                    Text("\(category.templates.count) habits")
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
    }
}

// MARK: - Template Row

struct TemplateRow: View {
    let template: HabitTemplate
    let categoryName: String?
    let isAlreadyAdded: Bool
    let canAdd: Bool
    let isPremium: Bool
    let addAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: template.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: template.color))
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(template.name)
                    .font(.body)
                Text(template.description)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                if let categoryName {
                    Text(categoryName)
                        .font(.caption2)
                        .foregroundStyle(Color.secondaryText.opacity(0.7))
                }
            }

            Spacer()

            if isAlreadyAdded {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentGreen)
            } else if canAdd {
                Button {
                    withAnimation {
                        addAction()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentSkyBlue)
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    HabitTemplateLibraryView()
        .modelContainer(for: [Habit.self, HabitCompletion.self], inMemory: true)
        .preferredColorScheme(.dark)
}
