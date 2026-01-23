import SwiftUI
import StoreKit

// MARK: - Streak Milestone Celebration View
/// Full-screen celebration when user hits a streak milestone

struct StreakMilestoneCelebrationView: View {
    @Environment(\.requestReview) private var requestReview

    let milestone: Int
    let onDismiss: () -> Void

    @State private var showConfetti = false
    @State private var badgeScale: CGFloat = 0.1
    @State private var textOpacity: Double = 0
    @State private var showShareButton = false

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            // Confetti
            if showConfetti {
                ConfettiView()
            }

            VStack(spacing: 32) {
                Spacer()

                // Badge
                ZStack {
                    // Glow
                    Circle()
                        .fill(milestoneColor.opacity(0.3))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [milestoneColor, milestoneColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 160, height: 160)

                    VStack(spacing: 8) {
                        Text(milestoneEmoji)
                            .font(.system(size: 50))

                        Text("\(milestone)")
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("DAYS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.8))
                            .tracking(2)
                    }
                }
                .scaleEffect(badgeScale)

                VStack(spacing: 12) {
                    Text(milestoneTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text(milestoneMessage)
                        .font(.body)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .opacity(textOpacity)

                Spacer()

                VStack(spacing: 16) {
                    if showShareButton {
                        Button {
                            HapticManager.shared.mediumTap()
                            shareMilestone()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Achievement")
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(milestoneColor)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        Button {
                            HapticManager.shared.lightTap()
                            AppSettings.shared.celebrateMilestone(milestone)
                            // Request review at key milestones (7, 21, 100 days)
                            if shouldRequestReview {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    requestReview()
                                }
                            }
                            onDismiss()
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundStyle(Color.secondaryText)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showShareButton ? 1 : 0)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        HapticManager.shared.success()

        // Badge scale
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            badgeScale = 1.0
        }

        // Text fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            textOpacity = 1.0
        }

        // Confetti
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showConfetti = true
        }

        // Share button
        withAnimation(.easeOut(duration: 0.3).delay(0.8)) {
            showShareButton = true
        }
    }

    private var milestoneEmoji: String {
        switch milestone {
        case 7: return "🌟"
        case 14: return "✨"
        case 21: return "💫"
        case 30: return "🔥"
        case 50: return "💪"
        case 100: return "🏆"
        case 150: return "👑"
        case 200: return "💎"
        case 365: return "🎯"
        case 500: return "🚀"
        case 1000: return "🌈"
        default: return "⭐"
        }
    }

    private var milestoneTitle: String {
        switch milestone {
        case 7: return "First Week!"
        case 14: return "Two Weeks Strong!"
        case 21: return "Habit Formed!"
        case 30: return "One Month!"
        case 50: return "Fifty Days!"
        case 100: return "Century Club!"
        case 150: return "Legendary!"
        case 200: return "Unstoppable!"
        case 365: return "One Full Year!"
        case 500: return "Elite Status!"
        case 1000: return "Thousand Days!"
        default: return "Milestone!"
        }
    }

    private var milestoneMessage: String {
        switch milestone {
        case 7: return "You've built momentum! The first week is the hardest - and you crushed it."
        case 14: return "Two weeks of consistency! You're proving this isn't just a phase."
        case 21: return "They say 21 days forms a habit. You've officially made it a part of your life."
        case 30: return "A full month! Only 8% of people maintain habits this long. You're exceptional."
        case 50: return "Fifty days of dedication. Your future self is already thanking you."
        case 100: return "Triple digits! You're in the top 1% of habit builders worldwide."
        case 150: return "150 days. You've transformed this from a habit into a lifestyle."
        case 200: return "200 days! Your consistency is genuinely inspiring."
        case 365: return "ONE ENTIRE YEAR! You've achieved what most only dream of."
        case 500: return "500 days. You're not just building habits, you're building a legacy."
        case 1000: return "1000 DAYS! You are a monument to human dedication."
        default: return "Another milestone reached! Keep building your best life."
        }
    }

    private var milestoneColor: Color {
        switch milestone {
        case 7: return .blue
        case 14: return .cyan
        case 21: return .teal
        case 30: return .green
        case 50: return .orange
        case 100: return .yellow
        case 150: return .purple
        case 200: return .pink
        case 365: return .red
        case 500: return Color(hex: "#FFD700") // Gold
        case 1000: return Color(hex: "#E5E4E2") // Platinum
        default: return .accentGreen
        }
    }

    private func shareMilestone() {
        // Will integrate with ShareGridView or create share image
    }

    /// Request review at milestones where users feel most accomplished
    private var shouldRequestReview: Bool {
        // Only request at specific milestones: 7 (first week), 21 (habit formed), 100 (century)
        let reviewMilestones = [7, 21, 100]
        guard reviewMilestones.contains(milestone) else { return false }

        // Check if we've already asked for this milestone
        let key = "hasRequestedReview_\(milestone)"
        if UserDefaults.standard.bool(forKey: key) {
            return false
        }

        // Mark as requested
        UserDefaults.standard.set(true, forKey: key)
        return true
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
                animateParticles(in: geometry.size)
            }
        }
    }

    private func createParticles(in size: CGSize) {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

        particles = (0..<50).map { _ in
            ConfettiParticle(
                id: UUID(),
                position: CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: -20
                ),
                color: colors.randomElement()!,
                size: CGFloat.random(in: 6...12),
                opacity: 1.0
            )
        }
    }

    private func animateParticles(in size: CGSize) {
        for i in particles.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2...4)

            withAnimation(.easeIn(duration: duration).delay(delay)) {
                particles[i].position = CGPoint(
                    x: particles[i].position.x + CGFloat.random(in: -100...100),
                    y: size.height + 50
                )
                particles[i].opacity = 0
            }
        }
    }
}

struct ConfettiParticle: Identifiable {
    let id: UUID
    var position: CGPoint
    let color: Color
    let size: CGFloat
    var opacity: Double
}

// MARK: - Preview

#Preview {
    StreakMilestoneCelebrationView(milestone: 30) {
        print("Dismissed")
    }
}
