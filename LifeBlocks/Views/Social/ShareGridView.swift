import SwiftUI

// MARK: - Share Grid View
/// Generates shareable images of the user's habit grid

struct ShareGridView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let dayEntries: [DayEntry]
    let currentStreak: Int
    let longestStreak: Int

    @State private var selectedStyle: ShareStyle = .grid
    @State private var showingShareSheet = false
    @State private var shareImage: UIImage?
    @State private var isGenerating = false

    enum ShareStyle: String, CaseIterable {
        case grid = "Year Grid"
        case streak = "Streak Card"
        case stats = "Stats Card"

        var icon: String {
            switch self {
            case .grid: return "square.grid.3x3.fill"
            case .streak: return "flame.fill"
            case .stats: return "chart.bar.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Style picker
                Picker("Style", selection: $selectedStyle) {
                    ForEach(ShareStyle.allCases, id: \.self) { style in
                        Label(style.rawValue, systemImage: style.icon)
                            .tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Preview
                ScrollView {
                    Group {
                        switch selectedStyle {
                        case .grid:
                            YearGridShareCard(dayEntries: dayEntries, currentStreak: currentStreak)
                        case .streak:
                            StreakOnlyShareCard(currentStreak: currentStreak, longestStreak: longestStreak)
                        case .stats:
                            StatsShareCard(dayEntries: dayEntries, currentStreak: currentStreak, longestStreak: longestStreak)
                        }
                    }
                    .padding()
                }

                // Share button
                Button {
                    generateAndShare()
                } label: {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Text(isGenerating ? "Generating..." : "Share to Social")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(isGenerating)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("Share Your Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = shareImage {
                    ShareSheet(items: [
                        image,
                        "Check out my habit tracking progress! \(currentStreak) day streak 🔥 #Blocks"
                    ])
                }
            }
        }
    }

    private func generateAndShare() {
        isGenerating = true
        HapticManager.shared.lightTap()

        Task { @MainActor in
            let view: AnyView
            let size: CGSize

            switch selectedStyle {
            case .grid:
                view = AnyView(YearGridShareCard(dayEntries: dayEntries, currentStreak: currentStreak))
                size = CGSize(width: 400, height: 300)
            case .streak:
                view = AnyView(StreakOnlyShareCard(currentStreak: currentStreak, longestStreak: longestStreak))
                size = CGSize(width: 350, height: 400)
            case .stats:
                view = AnyView(StatsShareCard(dayEntries: dayEntries, currentStreak: currentStreak, longestStreak: longestStreak))
                size = CGSize(width: 350, height: 450)
            }

            shareImage = renderViewToImage(view: view, size: size)
            isGenerating = false
            showingShareSheet = true
            HapticManager.shared.success()
        }
    }

    @MainActor
    private func renderViewToImage(view: AnyView, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - Year Grid Share Card

struct YearGridShareCard: View {
    let dayEntries: [DayEntry]
    let currentStreak: Int

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Year in Habits")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)

                    Text("\(currentStreak) day streak 🔥")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                    Text("Blocks")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Mini year grid
            MiniYearGrid(dayEntries: dayEntries)

            // Legend
            HStack(spacing: 4) {
                Text("Less")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))

                ForEach(0..<5) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(colorForLevel(level))
                        .frame(width: 12, height: 12)
                }

                Text("More")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func colorForLevel(_ level: Int) -> Color {
        switch level {
        case 0: return Color.white.opacity(0.1)
        case 1: return Color.green.opacity(0.3)
        case 2: return Color.green.opacity(0.5)
        case 3: return Color.green.opacity(0.7)
        case 4: return Color.green
        default: return Color.white.opacity(0.1)
        }
    }
}

// MARK: - Mini Year Grid

struct MiniYearGrid: View {
    let dayEntries: [DayEntry]

    private let weeks = 52
    private let squareSize: CGFloat = 6
    private let spacing: CGFloat = 2

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            ForEach(0..<weeks, id: \.self) { weekIndex in
                VStack(spacing: spacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        let date = dateFor(week: weekIndex, day: dayIndex)
                        RoundedRectangle(cornerRadius: 1)
                            .fill(colorForDate(date))
                            .frame(width: squareSize, height: squareSize)
                    }
                }
            }
        }
    }

    private func dateFor(week: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let startDate = calendar.date(byAdding: .weekOfYear, value: -(weeks - 1 - week), to: startOfWeek)!
        return calendar.date(byAdding: .day, value: day, to: startDate)!
    }

    private func colorForDate(_ date: Date) -> Color {
        guard date <= Date() else { return Color.white.opacity(0.05) }

        if let entry = dayEntries.first(where: { $0.date.isSameDay(as: date) }) {
            let level = entry.totalScore
            switch level {
            case 0: return Color.white.opacity(0.1)
            case 1...2: return Color.green.opacity(0.3)
            case 3...4: return Color.green.opacity(0.5)
            case 5...6: return Color.green.opacity(0.7)
            default: return Color.green
            }
        }
        return Color.white.opacity(0.1)
    }
}

// MARK: - Streak Only Share Card

struct StreakOnlyShareCard: View {
    let currentStreak: Int
    let longestStreak: Int

    var body: some View {
        VStack(spacing: 24) {
            // Flame icon
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Streak number
            Text("\(currentStreak)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("DAY STREAK")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white.opacity(0.8))
                .tracking(4)

            // Best streak
            if longestStreak > currentStreak {
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("Best: \(longestStreak) days")
                        .foregroundStyle(.white.opacity(0.6))
                }
                .font(.subheadline)
            }

            Spacer()

            // App branding
            HStack {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundStyle(.green)
                Text("Blocks")
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .font(.subheadline)
        }
        .padding(32)
        .frame(width: 350, height: 400)
        .background(
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "0f0f1a")],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

// MARK: - Stats Share Card

struct StatsShareCard: View {
    let dayEntries: [DayEntry]
    let currentStreak: Int
    let longestStreak: Int

    private var totalCheckIns: Int {
        dayEntries.filter { $0.checkedIn }.count
    }

    private var thisWeekCheckIns: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
        return dayEntries.filter { $0.date >= weekAgo && $0.checkedIn }.count
    }

    private var averageScore: Double {
        let scored = dayEntries.filter { $0.checkedIn }
        guard !scored.isEmpty else { return 0 }
        return Double(scored.map { $0.totalScore }.reduce(0, +)) / Double(scored.count)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("My Stats")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                    Text("Blocks")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundStyle(.green)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Stats grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(title: "Current Streak", value: "\(currentStreak)", unit: "days", icon: "flame.fill", color: .orange)
                StatItem(title: "Longest Streak", value: "\(longestStreak)", unit: "days", icon: "trophy.fill", color: .yellow)
                StatItem(title: "Total Check-ins", value: "\(totalCheckIns)", unit: "days", icon: "checkmark.circle.fill", color: .green)
                StatItem(title: "This Week", value: "\(thisWeekCheckIns)/7", unit: "days", icon: "calendar", color: .blue)
            }

            Divider()
                .background(Color.white.opacity(0.2))

            // Average score
            HStack {
                Text("Average Score")
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(String(format: "%.1f", averageScore))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
                Text("/ 10")
                    .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 350, height: 450)
        .background(
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


// MARK: - Preview

#Preview {
    ShareGridView(
        dayEntries: [],
        currentStreak: 42,
        longestStreak: 50
    )
    .preferredColorScheme(.dark)
}
