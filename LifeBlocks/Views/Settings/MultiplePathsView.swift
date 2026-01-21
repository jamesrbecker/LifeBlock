import SwiftUI

// MARK: - Multiple Paths View (Premium Feature)
/// Allows premium users to track up to 3 life paths simultaneously

struct MultiplePathsView: View {
    @State private var settings = AppSettings.shared
    @State private var primaryPath: LifePathCategory?
    @State private var secondaryPath: LifePathCategory?
    @State private var tertiaryPath: LifePathCategory?
    @State private var showingPathPicker = false
    @State private var editingSlot: PathSlot = .secondary

    enum PathSlot {
        case primary, secondary, tertiary
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Track Multiple Life Areas")
                        .font(.headline)
                    Text("Premium users can track up to 3 paths simultaneously. Get habits from multiple areas combined into your daily check-in.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
            }

            Section("Active Paths") {
                // Primary Path (always set during onboarding)
                PathRow(
                    title: "Primary Path",
                    path: primaryPath,
                    isRequired: true,
                    onTap: {
                        editingSlot = .primary
                        showingPathPicker = true
                    }
                )

                // Secondary Path (Premium)
                PathRow(
                    title: "Secondary Path",
                    path: secondaryPath,
                    isRequired: false,
                    onTap: {
                        editingSlot = .secondary
                        showingPathPicker = true
                    },
                    onRemove: {
                        secondaryPath = nil
                        settings.secondaryPath = nil
                    }
                )

                // Tertiary Path (Premium)
                PathRow(
                    title: "Third Path",
                    path: tertiaryPath,
                    isRequired: false,
                    onTap: {
                        editingSlot = .tertiary
                        showingPathPicker = true
                    },
                    onRemove: {
                        tertiaryPath = nil
                        settings.tertiaryPath = nil
                    }
                )
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Label("How it works", systemImage: "questionmark.circle")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Habits from all paths appear in your daily check-in")
                        BulletPoint(text: "Each path contributes to your activity score")
                        BulletPoint(text: "View progress per path in the dashboard")
                        BulletPoint(text: "Perfect for balancing career + fitness + creative pursuits")
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Multiple Paths")
        .sheet(isPresented: $showingPathPicker) {
            PathPickerSheet(
                selectedPath: bindingForSlot(editingSlot),
                excludedPaths: currentlySelectedPaths(),
                onSelect: { path in
                    updatePath(path, for: editingSlot)
                    showingPathPicker = false
                }
            )
        }
        .onAppear {
            loadCurrentPaths()
        }
    }

    private func loadCurrentPaths() {
        primaryPath = settings.userLifePath?.selectedPath
        secondaryPath = settings.secondaryPath
        tertiaryPath = settings.tertiaryPath
    }

    private func bindingForSlot(_ slot: PathSlot) -> Binding<LifePathCategory?> {
        switch slot {
        case .primary: return $primaryPath
        case .secondary: return $secondaryPath
        case .tertiary: return $tertiaryPath
        }
    }

    private func currentlySelectedPaths() -> [LifePathCategory] {
        [primaryPath, secondaryPath, tertiaryPath].compactMap { $0 }
    }

    private func updatePath(_ path: LifePathCategory, for slot: PathSlot) {
        switch slot {
        case .primary:
            primaryPath = path
            // Note: Primary path update would need to update userLifePath
        case .secondary:
            secondaryPath = path
            settings.secondaryPath = path
        case .tertiary:
            tertiaryPath = path
            settings.tertiaryPath = path
        }
    }
}

// MARK: - Path Row

struct PathRow: View {
    let title: String
    let path: LifePathCategory?
    let isRequired: Bool
    let onTap: () -> Void
    var onRemove: (() -> Void)? = nil

    var body: some View {
        Button(action: onTap) {
            HStack {
                if let path = path {
                    Image(systemName: path.icon)
                        .font(.title2)
                        .foregroundStyle(path.color)
                        .frame(width: 40)

                    VStack(alignment: .leading) {
                        Text(path.displayName)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text(title)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                } else {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.accentGreen)
                        .frame(width: 40)

                    VStack(alignment: .leading) {
                        Text("Add \(title)")
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text("Tap to select a path")
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                Spacer()

                if path != nil && !isRequired {
                    Button(action: { onRemove?() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.secondaryText)
                    }
                    .buttonStyle(.plain)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Path Picker Sheet

struct PathPickerSheet: View {
    @Binding var selectedPath: LifePathCategory?
    let excludedPaths: [LifePathCategory]
    let onSelect: (LifePathCategory) -> Void

    @Environment(\.dismiss) private var dismiss

    var availablePaths: [LifePathCategory] {
        LifePathCategory.allCases.filter { $0 != .custom && !excludedPaths.contains($0) }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(availablePaths, id: \.self) { path in
                    Button(action: { onSelect(path) }) {
                        HStack {
                            Image(systemName: path.icon)
                                .font(.title2)
                                .foregroundStyle(path.color)
                                .frame(width: 40)

                            VStack(alignment: .leading) {
                                Text(path.displayName)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text(path.tagline)
                                    .font(.caption)
                                    .foregroundStyle(Color.secondaryText)
                            }

                            Spacer()

                            if selectedPath == path {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color.accentGreen)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .navigationTitle("Choose Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Bullet Point

struct BulletPoint: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(Color.secondaryText)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        MultiplePathsView()
    }
    .preferredColorScheme(.dark)
}
