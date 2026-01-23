import SwiftUI

// MARK: - Path Discovery Prompt View

struct PathDiscoveryPromptView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedPath: LifePathCategory?
    @State private var showingPathSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Celebration header
                ZStack {
                    Circle()
                        .fill(Color.accentGreen.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "star.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.accentGreen)
                }

                VStack(spacing: 12) {
                    Text("You've Been Crushing It!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primaryText)

                    Text("You've been building great habits. Ready to focus your journey with a specific path?")
                        .font(.body)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                Spacer()

                // Options
                VStack(spacing: 12) {
                    Button {
                        showingPathSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "target")
                            Text("Choose My Path")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        AppSettings.shared.hasDeclinedPathSuggestion = true
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right")
                            Text("Keep Exploring")
                        }
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color.gridBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        AppSettings.shared.hasDeclinedPathSuggestion = true
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
            .sheet(isPresented: $showingPathSelection) {
                PathSelectionSheet(selectedPath: $selectedPath) { path in
                    let lifePath = UserLifePath(path: path)
                    AppSettings.shared.userLifePath = lifePath
                    AppSettings.shared.isExplorationMode = false
                    AppSettings.shared.hasDeclinedPathSuggestion = true

                    for (index, template) in path.suggestedHabits.prefix(6).enumerated() {
                        let habit = Habit(
                            name: template.name,
                            icon: template.icon,
                            colorHex: template.color
                        )
                        habit.sortOrder = 100 + index
                        modelContext.insert(habit)
                    }

                    try? modelContext.save()
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Path Selection Sheet

struct PathSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedPath: LifePathCategory?
    let onSelect: (LifePathCategory) -> Void

    private var pathsByCategory: [(String, [LifePathCategory])] {
        [
            ("Popular", [.contentCreator, .entrepreneur, .softwareEngineer, .fitnessInfluencer, .student]),
            ("Healthcare", [.doctor, .nurse, .emt, .physicalTherapist, .dentalPro]),
            ("Trades", [.electrician, .plumber, .welder, .construction, .hvacTech, .carpenter, .mechanic, .truckDriver]),
            ("Creative", [.musician, .actor, .writer, .creative, .gameDeveloper]),
            ("Professional", [.teacher, .lawyer, .realEstate, .chef, .pilot, .sales]),
            ("Other", [.military, .firstResponder, .athlete, .investor, .healthWellness, .parent, .digitalNomad])
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ForEach(pathsByCategory, id: \.0) { category, paths in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category)
                                .font(.headline)
                                .foregroundStyle(Color.primaryText)
                                .padding(.horizontal)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(paths, id: \.self) { path in
                                    PathMiniCard(
                                        path: path,
                                        isSelected: selectedPath == path
                                    ) {
                                        HapticManager.shared.lightTap()
                                        selectedPath = path
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color.gridBackground)
            .navigationTitle("Choose Your Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondaryText)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Select") {
                        if let path = selectedPath {
                            onSelect(path)
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(selectedPath == nil)
                }
            }
        }
    }
}

// MARK: - Path Mini Card

struct PathMiniCard: View {
    let path: LifePathCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: path.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : path.color)

                Text(path.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(isSelected ? .white : Color.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? path.color : Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? path.color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PathDiscoveryPromptView()
        .modelContainer(for: [Habit.self], inMemory: true)
        .preferredColorScheme(.dark)
}
