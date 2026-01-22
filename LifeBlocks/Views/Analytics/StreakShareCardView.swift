import SwiftUI

// MARK: - Streak Share Card View
/// A beautiful, shareable card that displays user's streak progress

struct StreakShareCardView: View {
    let streakDays: Int
    let pathCategory: LifePathCategory
    let userName: String
    let miniGrid: [[Int]] // 7x5 grid of activity levels (0-4)

    @Environment(\.colorScheme) var colorScheme

    private var milestoneTitle: String {
        switch streakDays {
        case 7: return "1 WEEK"
        case 14: return "2 WEEKS"
        case 21: return "21 DAYS"
        case 30: return "1 MONTH"
        case 50: return "50 DAYS"
        case 100: return "100 DAYS"
        case 365: return "1 YEAR"
        default: return "\(streakDays) DAYS"
        }
    }

    private var celebrationEmoji: String {
        switch streakDays {
        case 7: return "🔥"
        case 14: return "⚡️"
        case 21: return "💪"
        case 30: return "🏆"
        case 50: return "🌟"
        case 100: return "💯"
        case 365: return "👑"
        default: return "✨"
        }
    }

    private var motivationalText: String {
        switch streakDays {
        case 7: return "Building momentum!"
        case 14: return "Consistency is key!"
        case 21: return "Habit formed!"
        case 30: return "Unstoppable!"
        case 50: return "Halfway to 100!"
        case 100: return "Triple digits!"
        case 365: return "Legendary!"
        default: return "Keep going!"
        }
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    pathCategory.color.opacity(0.8),
                    pathCategory.color.opacity(0.4),
                    Color.black.opacity(0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 20) {
                // Top section - App branding
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                    Text("Blocks")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Image(systemName: pathCategory.icon)
                        .font(.title2)
                        .foregroundColor(pathCategory.color)
                }
                .padding(.horizontal)

                Spacer()

                // Main content
                VStack(spacing: 16) {
                    // Celebration emoji
                    Text(celebrationEmoji)
                        .font(.system(size: 60))

                    // Streak number
                    Text(milestoneTitle)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    // Motivational text
                    Text(motivationalText)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))

                    // Mini contribution grid
                    MiniGridView(grid: miniGrid, accentColor: pathCategory.color)
                        .frame(height: 80)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                }

                Spacer()

                // Bottom section - Path info
                VStack(spacing: 8) {
                    Text(pathCategory.displayName.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(pathCategory.color)
                        .tracking(2)

                    Text("Build Your Life. Block by Block.")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 20)
            }
            .padding()
        }
        .frame(width: 350, height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Mini Grid View
/// Compact version of the contribution grid for sharing

struct MiniGridView: View {
    let grid: [[Int]] // 7 columns x 5 rows
    let accentColor: Color

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { col in
                VStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { row in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(colorForLevel(grid[safe: col]?[safe: row] ?? 0))
                            .frame(width: 12, height: 12)
                    }
                }
            }
        }
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.white.opacity(0.1)
        case 1: return accentColor.opacity(0.3)
        case 2: return accentColor.opacity(0.5)
        case 3: return accentColor.opacity(0.7)
        case 4: return accentColor
        default: return Color.white.opacity(0.1)
        }
    }
}

// MARK: - Array Safe Subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Share Card Generator
/// Renders the share card as an image for sharing

struct ShareCardGenerator {
    @MainActor
    static func generateImage(
        streakDays: Int,
        pathCategory: LifePathCategory,
        userName: String,
        miniGrid: [[Int]]
    ) -> UIImage? {
        let view = StreakShareCardView(
            streakDays: streakDays,
            pathCategory: pathCategory,
            userName: userName,
            miniGrid: miniGrid
        )

        let controller = UIHostingController(rootView: view)
        let size = CGSize(width: 350, height: 500)

        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Share Sheet Helper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Milestone Share Button
/// Button that appears when user hits a milestone

struct MilestoneShareButton: View {
    let streakDays: Int
    let pathCategory: LifePathCategory
    let userName: String
    let recentActivity: [DayEntry]

    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?

    private var isMilestone: Bool {
        [7, 14, 21, 30, 50, 100, 200, 365].contains(streakDays)
    }

    var body: some View {
        Button(action: generateAndShare) {
            HStack {
                Image(systemName: "square.and.arrow.up")
                Text("Share Milestone")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(pathCategory.color)
            .clipShape(Capsule())
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = shareImage {
                ShareSheet(items: [image, "I just hit \(streakDays) days on my \(pathCategory.displayName) journey! 🔥 #Blocks"])
            }
        }
    }

    private func generateAndShare() {
        let grid = generateMiniGrid()
        Task { @MainActor in
            shareImage = ShareCardGenerator.generateImage(
                streakDays: streakDays,
                pathCategory: pathCategory,
                userName: userName,
                miniGrid: grid
            )
            showingShareSheet = true
        }
    }

    private func generateMiniGrid() -> [[Int]] {
        // Generate a 7x5 grid from recent activity (last 35 days)
        var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 5), count: 7)

        let sortedEntries = recentActivity
            .sorted { $0.date > $1.date }
            .prefix(35)

        for (index, entry) in sortedEntries.enumerated() {
            let col = index / 5
            let row = index % 5
            if col < 7 && row < 5 {
                grid[col][row] = entry.intensityLevel.rawValue
            }
        }

        return grid
    }
}

// MARK: - Preview

#Preview {
    StreakShareCardView(
        streakDays: 30,
        pathCategory: .entrepreneur,
        userName: "James",
        miniGrid: [
            [4, 3, 4, 2, 3],
            [3, 4, 3, 4, 2],
            [4, 2, 3, 4, 3],
            [3, 4, 4, 3, 4],
            [4, 3, 2, 4, 3],
            [3, 4, 3, 4, 4],
            [4, 4, 3, 4, 3]
        ]
    )
    .padding()
    .background(Color.black)
}
