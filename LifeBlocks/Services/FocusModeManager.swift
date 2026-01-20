import Foundation
import Intents
import SwiftUI

// MARK: - Focus Mode Manager
/// Integrates with iOS Focus Modes to suggest relevant habits

@MainActor
class FocusModeManager: ObservableObject {
    static let shared = FocusModeManager()

    @Published var currentFocusMode: String?
    @Published var suggestedHabits: [String] = []

    private init() {
        // Check focus status periodically
        startFocusMonitoring()
    }

    func startFocusMonitoring() {
        // Request Focus Status authorization
        Task {
            await checkFocusStatus()
        }

        // Schedule periodic checks
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.checkFocusStatus()
            }
        }
    }

    func checkFocusStatus() async {
        // In iOS 15+, we can check if Focus is active
        // Note: Full focus name requires special entitlement
        let center = INFocusStatusCenter.default

        // Request authorization if needed
        let status = center.authorizationStatus
        if status == .notDetermined {
            center.requestAuthorization { _ in }
        }

        let focusStatus = center.focusStatus

        if focusStatus.isFocused == true {
            // Focus is active but we may not have access to the specific focus name
            // We'll use a generic approach based on time of day and user patterns
            await updateSuggestedHabits(forFocusActive: true)
        } else {
            currentFocusMode = nil
            suggestedHabits = []
        }
    }

    private func updateSuggestedHabits(forFocusActive: Bool) async {
        guard forFocusActive else {
            suggestedHabits = []
            return
        }

        // Suggest habits based on time of day when focus is active
        let hour = Calendar.current.component(.hour, from: Date())

        let habitSuggestions: [String]

        switch hour {
        case 5..<9:
            // Morning - suggest morning routine habits
            currentFocusMode = "Morning"
            habitSuggestions = ["Morning Workout", "Meditate", "Journal", "Healthy Breakfast"]

        case 9..<12:
            // Morning work hours
            currentFocusMode = "Work"
            habitSuggestions = ["Deep Work", "Revenue Activity", "Important Tasks", "No Distractions"]

        case 12..<14:
            // Lunch
            currentFocusMode = "Break"
            habitSuggestions = ["Healthy Lunch", "Walk", "Rest", "Connect with Others"]

        case 14..<18:
            // Afternoon work
            currentFocusMode = "Work"
            habitSuggestions = ["Deep Work", "Meetings", "Follow-ups", "Admin Tasks"]

        case 18..<21:
            // Evening
            currentFocusMode = "Personal"
            habitSuggestions = ["Exercise", "Family Time", "Hobbies", "Learning"]

        case 21..<24, 0..<5:
            // Night/Sleep
            currentFocusMode = "Sleep"
            habitSuggestions = ["Wind Down", "No Screens", "Reading", "Sleep Routine"]

        default:
            currentFocusMode = nil
            habitSuggestions = []
        }

        suggestedHabits = habitSuggestions
    }

    // MARK: - Focus Mode Habit Mapping

    static let focusModeHabits: [String: [String]] = [
        "Work": [
            "Deep Work",
            "Revenue Activity",
            "Important Tasks",
            "Code",
            "Sales Outreach",
            "Email Zero"
        ],
        "Personal": [
            "Self-Care",
            "Exercise",
            "Meditate",
            "Read",
            "Hobbies",
            "Quality Time"
        ],
        "Fitness": [
            "Morning Workout",
            "Track Macros",
            "Recovery",
            "10K Steps",
            "Stretch",
            "Hydrate"
        ],
        "Sleep": [
            "Sleep 8 Hours",
            "No Screens",
            "Wind Down",
            "Journal",
            "Meditate"
        ],
        "Driving": [],
        "Reading": [
            "Read",
            "Learn",
            "Study Session",
            "Take Notes"
        ],
        "Mindfulness": [
            "Meditate",
            "Breathwork",
            "Journal",
            "Gratitude",
            "Nature"
        ]
    ]

    func getHabitsForFocusMode(_ mode: String) -> [String] {
        Self.focusModeHabits[mode] ?? []
    }
}

// MARK: - Focus Status View Component

struct FocusStatusView: View {
    @StateObject private var focusManager = FocusModeManager.shared

    var body: some View {
        if let focusMode = focusManager.currentFocusMode {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: focusIcon(for: focusMode))
                        .foregroundStyle(.purple)

                    Text("\(focusMode) Focus Active")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()
                }

                if !focusManager.suggestedHabits.isEmpty {
                    Text("Suggested habits:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(focusManager.suggestedHabits, id: \.self) { habit in
                            Text(habit)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.purple.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func focusIcon(for mode: String) -> String {
        switch mode.lowercased() {
        case "work": return "briefcase.fill"
        case "personal": return "person.fill"
        case "fitness": return "figure.run"
        case "sleep": return "moon.fill"
        case "driving": return "car.fill"
        case "reading": return "book.fill"
        case "mindfulness": return "brain.head.profile"
        case "morning": return "sunrise.fill"
        case "break": return "cup.and.saucer.fill"
        default: return "moon.circle.fill"
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.width ?? 0,
            spacing: spacing,
            subviews: subviews
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            spacing: spacing,
            subviews: subviews
        )

        for (index, line) in result.lines.enumerated() {
            var x = bounds.minX

            for item in line {
                let position = CGPoint(x: x, y: bounds.minY + result.lineYOffsets[index])
                subviews[item.index].place(
                    at: position,
                    proposal: ProposedViewSize(item.size)
                )
                x += item.size.width + spacing
            }
        }
    }

    struct FlowResult {
        var lines: [[Item]] = []
        var lineYOffsets: [CGFloat] = []
        var size: CGSize = .zero

        struct Item {
            var index: Int
            var size: CGSize
        }

        init(in width: CGFloat, spacing: CGFloat, subviews: Subviews) {
            var currentLine: [Item] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxWidth: CGFloat = 0

            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > width && !currentLine.isEmpty {
                    lines.append(currentLine)
                    lineYOffsets.append(currentY)
                    currentY += lineHeight + spacing
                    currentLine = []
                    currentX = 0
                    lineHeight = 0
                }

                currentLine.append(Item(index: index, size: size))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
                maxWidth = max(maxWidth, currentX)
            }

            if !currentLine.isEmpty {
                lines.append(currentLine)
                lineYOffsets.append(currentY)
                currentY += lineHeight
            }

            size = CGSize(width: maxWidth, height: currentY)
        }
    }
}

// MARK: - Focus Settings View

struct FocusSettingsView: View {
    @AppStorage("focusIntegrationEnabled") private var focusIntegrationEnabled = true
    @StateObject private var focusManager = FocusModeManager.shared

    var body: some View {
        Form {
            Section {
                Toggle("Focus Mode Integration", isOn: $focusIntegrationEnabled)

                if focusIntegrationEnabled {
                    HStack {
                        Text("Current Status")
                        Spacer()
                        if let mode = focusManager.currentFocusMode {
                            Label(mode, systemImage: "moon.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.purple)
                        } else {
                            Text("No Focus Active")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } footer: {
                Text("When enabled, LifeBlocks will suggest relevant habits based on your active Focus mode.")
            }

            if focusIntegrationEnabled {
                Section("Focus Mode Habits") {
                    ForEach(Array(FocusModeManager.focusModeHabits.keys.sorted()), id: \.self) { mode in
                        DisclosureGroup {
                            ForEach(FocusModeManager.focusModeHabits[mode] ?? [], id: \.self) { habit in
                                Text(habit)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        } label: {
                            Label(mode, systemImage: focusIcon(for: mode))
                        }
                    }
                }
            }
        }
        .navigationTitle("Focus Mode")
    }

    private func focusIcon(for mode: String) -> String {
        switch mode {
        case "Work": return "briefcase.fill"
        case "Personal": return "person.fill"
        case "Fitness": return "figure.run"
        case "Sleep": return "moon.fill"
        case "Driving": return "car.fill"
        case "Reading": return "book.fill"
        case "Mindfulness": return "brain.head.profile"
        default: return "moon.circle.fill"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        FocusSettingsView()
    }
    .preferredColorScheme(.dark)
}
