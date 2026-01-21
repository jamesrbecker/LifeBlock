import SwiftUI

// Preview file to compare app icon color schemes
// Open this file and use the Canvas preview to see both icons

struct AppIconPreview: View {
    var body: some View {
        HStack(spacing: 40) {
            VStack(spacing: 16) {
                AppIconView(colorScheme: .green)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                Text("Green (Current)")
                    .font(.headline)
            }

            VStack(spacing: 16) {
                AppIconView(colorScheme: .skyblue)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 40))
                Text("Sky Blue")
                    .font(.headline)
            }
        }
        .padding(40)
        .background(Color.black)
    }
}

struct AppIconView: View {
    let colorScheme: IconColorScheme

    private let gridSize = 3
    private let spacing: CGFloat = 12

    var body: some View {
        GeometryReader { geometry in
            let totalSpacing = spacing * CGFloat(gridSize - 1)
            let availableSize = min(geometry.size.width, geometry.size.height) - 40 // padding
            let squareSize = (availableSize - totalSpacing) / CGFloat(gridSize)

            ZStack {
                // Background
                Color(hex: "#0D1117")

                // Grid
                VStack(spacing: spacing) {
                    ForEach(0..<gridSize, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<gridSize, id: \.self) { col in
                                let level = levelForPosition(row: row, col: col)
                                RoundedRectangle(cornerRadius: squareSize * 0.2)
                                    .fill(colorScheme.color(for: level))
                                    .frame(width: squareSize, height: squareSize)
                            }
                        }
                    }
                }
            }
        }
    }

    // Creates gradient from top-left (dark) to bottom-right (bright)
    private func levelForPosition(row: Int, col: Int) -> Int {
        let position = row + col
        switch position {
        case 0: return 1      // top-left
        case 1: return 2      // top-center, middle-left
        case 2: return 3      // top-right, middle-center, bottom-left
        case 3: return 4      // middle-right, bottom-center
        case 4: return 4      // bottom-right
        default: return 2
        }
    }
}

enum IconColorScheme {
    case green
    case skyblue
    case lavender
    case purple
    case orange

    func color(for level: Int) -> Color {
        switch self {
        case .green:
            switch level {
            case 1: return Color(hex: "#0D3D1F")
            case 2: return Color(hex: "#1A7A3E")
            case 3: return Color(hex: "#28A745")
            case 4: return Color(hex: "#34C759")
            default: return Color(hex: "#161B22")
            }
        case .skyblue:
            switch level {
            case 1: return Color(hex: "#0C3A5A")
            case 2: return Color(hex: "#1877B8")
            case 3: return Color(hex: "#3DA5E0")
            case 4: return Color(hex: "#5AC8FA")
            default: return Color(hex: "#161B22")
            }
        case .lavender:
            switch level {
            case 1: return Color(hex: "#3D2E5C")
            case 2: return Color(hex: "#6B5B95")
            case 3: return Color(hex: "#9B8DC2")
            case 4: return Color(hex: "#BDB5D5")
            default: return Color(hex: "#161B22")
            }
        case .purple:
            switch level {
            case 1: return Color(hex: "#3D1F5C")
            case 2: return Color(hex: "#6E40C9")
            case 3: return Color(hex: "#8B5CF6")
            case 4: return Color(hex: "#A78BFA")
            default: return Color(hex: "#161B22")
            }
        case .orange:
            switch level {
            case 1: return Color(hex: "#5C2D0E")
            case 2: return Color(hex: "#9A3412")
            case 3: return Color(hex: "#EA580C")
            case 4: return Color(hex: "#FB923C")
            default: return Color(hex: "#161B22")
            }
        }
    }
}

// All color options comparison
struct AllIconColorsPreview: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 30) {
                ForEach([IconColorScheme.green, .skyblue, .lavender, .purple, .orange], id: \.self) { scheme in
                    VStack(spacing: 12) {
                        AppIconView(colorScheme: scheme)
                            .frame(width: 150, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                        Text(schemeName(scheme))
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(30)
        }
        .background(Color.black)
    }

    func schemeName(_ scheme: IconColorScheme) -> String {
        switch scheme {
        case .green: return "Green"
        case .skyblue: return "Sky Blue"
        case .lavender: return "Lavender"
        case .purple: return "Purple"
        case .orange: return "Orange"
        }
    }
}

#Preview("Green vs Sky Blue") {
    AppIconPreview()
}

#Preview("All Colors") {
    AllIconColorsPreview()
}
