import SwiftUI

// MARK: - Badges View

struct BadgesView: View {
    @StateObject private var tracker = BadgeTracker.shared
    @StateObject private var purchases = PurchaseManager.shared
    @State private var selectedCategory: BadgeCategory?
    @State private var showingPremium = false

    var body: some View {
        Group {
            if purchases.isPremium {
                badgeContent
            } else {
                premiumGateView
            }
        }
        .navigationTitle("Badges")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if purchases.isPremium {
                tracker.checkAndAwardBadges()
            }
        }
        .sheet(isPresented: $showingPremium) {
            PremiumView()
        }
    }

    // MARK: - Badge Content (Premium)

    private var badgeContent: some View {
        List {
            // Progress summary
            Section {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(tracker.earnedCount) / \(tracker.totalCount)")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Badges Earned")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }

                        Spacer()

                        // Progress ring
                        ZStack {
                            Circle()
                                .stroke(Color.borderColor, lineWidth: 6)
                                .frame(width: 60, height: 60)

                            Circle()
                                .trim(from: 0, to: Double(tracker.earnedCount) / Double(max(tracker.totalCount, 1)))
                                .stroke(Color.accentGreen, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))

                            Text("\(Int(Double(tracker.earnedCount) / Double(max(tracker.totalCount, 1)) * 100))%")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // Category filter
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            name: "All",
                            icon: "square.grid.2x2.fill",
                            color: .gray,
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }

                        ForEach(BadgeCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                name: category.rawValue,
                                icon: category.icon,
                                color: category.color,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            // Earned badges
            let earned = filteredBadges.filter { tracker.isEarned($0) }
            if !earned.isEmpty {
                Section("Earned") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                        ForEach(earned, id: \.id) { badge in
                            BadgeCell(badge: badge, isEarned: true, progress: 1.0)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }

            // Locked badges
            let locked = filteredBadges.filter { !tracker.isEarned($0) }
            if !locked.isEmpty {
                Section("In Progress") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 16) {
                        ForEach(locked, id: \.id) { badge in
                            BadgeCell(
                                badge: badge,
                                isEarned: false,
                                progress: tracker.progress(for: badge)
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    // MARK: - Premium Gate

    private var premiumGateView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "medal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("Badges & Achievements")
                .font(.title2)
                .fontWeight(.bold)

            Text("Unlock \(BadgeCatalog.allBadges.count) badges as you build habits, maintain streaks, and achieve milestones. Track your progress and show off your achievements.")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // Preview some badges
            HStack(spacing: 16) {
                ForEach(BadgeCatalog.streakBadges.prefix(3), id: \.id) { badge in
                    VStack(spacing: 6) {
                        Image(systemName: badge.icon)
                            .font(.title)
                            .foregroundStyle(badge.tier.color)
                        Text(badge.name)
                            .font(.caption2)
                            .foregroundStyle(Color.secondaryText)
                    }
                    .frame(width: 80)
                }
            }
            .padding(.vertical, 8)

            Button {
                showingPremium = true
            } label: {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade to Premium")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.accentGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 32)

            Spacer()
        }
    }

    // MARK: - Helpers

    private var filteredBadges: [Badge] {
        if let category = selectedCategory {
            return BadgeCatalog.allBadges.filter { $0.category == category }
        }
        return BadgeCatalog.allBadges
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color.opacity(0.2) : Color.secondary.opacity(0.1))
            .foregroundStyle(isSelected ? color : Color.secondaryText)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Badge Cell

struct BadgeCell: View {
    let badge: Badge
    let isEarned: Bool
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isEarned ? badge.tier.color.opacity(0.2) : Color.secondary.opacity(0.1))
                    .frame(width: 64, height: 64)

                if !isEarned {
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(badge.tier.color.opacity(0.4), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                }

                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundStyle(isEarned ? badge.tier.color : Color.secondaryText.opacity(0.5))
            }

            Text(badge.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundStyle(isEarned ? .primary : Color.secondaryText)
                .lineLimit(2)

            if isEarned {
                Text(badge.tier.displayName)
                    .font(.system(size: 9))
                    .fontWeight(.semibold)
                    .foregroundStyle(badge.tier.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(badge.tier.color.opacity(0.15))
                    .clipShape(Capsule())
            } else {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 9))
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .frame(minWidth: 80)
        .opacity(isEarned ? 1 : 0.7)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        BadgesView()
    }
    .preferredColorScheme(.dark)
}
