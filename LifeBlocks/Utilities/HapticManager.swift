import SwiftUI
import UIKit

/// Centralized haptic feedback manager for consistent tactile feedback throughout the app
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Impact Feedback

    /// Light tap - for selections, toggles
    func lightTap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    /// Medium tap - for button presses, card selections
    func mediumTap() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Heavy tap - for significant actions
    func heavyTap() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }

    // MARK: - Notification Feedback

    /// Success - habit completed, check-in done, streak achieved
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Warning - streak at risk, approaching limit
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }

    /// Error - something went wrong
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    // MARK: - Selection Feedback

    /// Selection changed - for pickers, segmented controls
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Double tap pattern - for extra special moments (milestones)
    func celebration() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            generator.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let success = UINotificationFeedbackGenerator()
            success.notificationOccurred(.success)
        }
    }

    /// Streak milestone - satisfying pattern for streak achievements
    func streakMilestone() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            generator.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            generator.impactOccurred()
        }
    }
}
