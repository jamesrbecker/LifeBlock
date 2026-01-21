import SwiftUI

struct QuestionCardView: View {
    let habit: Habit
    let onAnswer: (Int) -> Void

    @State private var offset: CGFloat = 0
    @State private var selectedAnswer: Int?

    var body: some View {
        VStack(spacing: 24) {
            // Habit icon and name
            VStack(spacing: 12) {
                Image(systemName: habit.icon)
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: habit.colorHex))

                Text("Did you \(habit.name.lowercased()) today?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)

            Spacer()

            // Answer buttons
            VStack(spacing: 12) {
                AnswerButton(
                    title: "Yes!",
                    subtitle: "Fully completed",
                    icon: "checkmark.circle.fill",
                    color: .accentGreen,
                    isSelected: selectedAnswer == 2
                ) {
                    selectAnswer(2)
                }

                AnswerButton(
                    title: "Partially",
                    subtitle: "Some progress",
                    icon: "circle.lefthalf.filled",
                    color: .yellow,
                    isSelected: selectedAnswer == 1
                ) {
                    selectAnswer(1)
                }

                AnswerButton(
                    title: "No",
                    subtitle: "Skipped today",
                    icon: "xmark.circle.fill",
                    color: .secondary,
                    isSelected: selectedAnswer == 0
                ) {
                    selectAnswer(0)
                }
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
        .offset(x: offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    offset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    if value.translation.width > threshold {
                        // Swipe right = Yes
                        swipeOff(direction: 1, answer: 2)
                    } else if value.translation.width < -threshold {
                        // Swipe left = No
                        swipeOff(direction: -1, answer: 0)
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
        )
        .rotationEffect(.degrees(Double(offset / 20)))
        .animation(.interactiveSpring(), value: offset)
    }

    private func selectAnswer(_ answer: Int) {
        selectedAnswer = answer

        // Haptic feedback based on answer
        if answer == 2 {
            HapticManager.shared.success()
        } else if answer == 1 {
            HapticManager.shared.mediumTap()
        } else {
            HapticManager.shared.lightTap()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onAnswer(answer)
        }
    }

    private func swipeOff(direction: CGFloat, answer: Int) {
        // Haptic on swipe
        if direction > 0 {
            HapticManager.shared.success()
        } else {
            HapticManager.shared.lightTap()
        }

        withAnimation(.easeOut(duration: 0.3)) {
            offset = direction * 500
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onAnswer(answer)
        }
    }
}

struct AnswerButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(color)
                        .fontWeight(.bold)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? color.opacity(0.2) : Color.gridBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? color : Color.borderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Color.gridBackground.ignoresSafeArea()

        QuestionCardView(
            habit: Habit(name: "Exercise", icon: "figure.run")
        ) { answer in
            print("Answered: \(answer)")
        }
        .padding(20)
    }
    .preferredColorScheme(.dark)
}
