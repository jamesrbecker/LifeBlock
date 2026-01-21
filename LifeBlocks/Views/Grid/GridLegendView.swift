import SwiftUI

struct GridLegendView: View {
    let colorScheme: GridColorScheme

    @Environment(\.colorScheme) private var systemColorScheme

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    var body: some View {
        HStack(spacing: 4) {
            Text("Less")
                .font(.caption2)
                .foregroundStyle(Color.secondaryText)

            ForEach(0..<5) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(colorScheme.color(for: level, isDarkMode: isDarkMode))
                    .frame(width: 10, height: 10)
            }

            Text("More")
                .font(.caption2)
                .foregroundStyle(Color.secondaryText)
        }
    }
}

// Extended legend with labels
struct GridLegendExtendedView: View {
    let colorScheme: GridColorScheme

    @Environment(\.colorScheme) private var systemColorScheme

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity Level")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(IntensityLevel.allCases, id: \.rawValue) { level in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(colorScheme.color(for: level.rawValue, isDarkMode: isDarkMode))
                        .frame(width: 16, height: 16)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(levelTitle(level))
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(level.description)
                            .font(.caption)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func levelTitle(_ level: IntensityLevel) -> String {
        switch level {
        case .none: return "Level 0"
        case .light: return "Level 1"
        case .medium: return "Level 2"
        case .high: return "Level 3"
        case .maximum: return "Level 4"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        GridLegendView(colorScheme: .green)

        GridLegendExtendedView(colorScheme: .green)
    }
    .padding()
    .background(Color.gridBackground)
    .preferredColorScheme(.dark)
}
