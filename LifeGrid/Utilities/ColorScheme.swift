import SwiftUI

// GitHub-style contribution colors
enum GridColorScheme: String, CaseIterable {
    case green = "green"      // Classic GitHub
    case blue = "blue"        // Ocean
    case purple = "purple"    // Violet
    case orange = "orange"    // Fire
    case pink = "pink"        // Rose

    var colors: [Color] {
        switch self {
        case .green:
            return [
                Color(hex: "#161B22"),  // Level 0 - Empty (dark mode bg)
                Color(hex: "#0E4429"),  // Level 1 - Light
                Color(hex: "#006D32"),  // Level 2 - Medium
                Color(hex: "#26A641"),  // Level 3 - High
                Color(hex: "#39D353")   // Level 4 - Maximum
            ]
        case .blue:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#0A3069"),
                Color(hex: "#0550AE"),
                Color(hex: "#218BFF"),
                Color(hex: "#58A6FF")
            ]
        case .purple:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#3D1F5C"),
                Color(hex: "#6E40C9"),
                Color(hex: "#8B5CF6"),
                Color(hex: "#A78BFA")
            ]
        case .orange:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#5C2D0E"),
                Color(hex: "#9A3412"),
                Color(hex: "#EA580C"),
                Color(hex: "#FB923C")
            ]
        case .pink:
            return [
                Color(hex: "#161B22"),
                Color(hex: "#5C1F4A"),
                Color(hex: "#9D174D"),
                Color(hex: "#DB2777"),
                Color(hex: "#F472B6")
            ]
        }
    }

    var lightModeColors: [Color] {
        switch self {
        case .green:
            return [
                Color(hex: "#EBEDF0"),  // Level 0 - Empty
                Color(hex: "#9BE9A8"),  // Level 1 - Light
                Color(hex: "#40C463"),  // Level 2 - Medium
                Color(hex: "#30A14E"),  // Level 3 - High
                Color(hex: "#216E39")   // Level 4 - Maximum
            ]
        case .blue:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#B6D4FF"),
                Color(hex: "#58A6FF"),
                Color(hex: "#218BFF"),
                Color(hex: "#0550AE")
            ]
        case .purple:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#DDD6FE"),
                Color(hex: "#A78BFA"),
                Color(hex: "#8B5CF6"),
                Color(hex: "#6E40C9")
            ]
        case .orange:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#FED7AA"),
                Color(hex: "#FB923C"),
                Color(hex: "#EA580C"),
                Color(hex: "#9A3412")
            ]
        case .pink:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#FBCFE8"),
                Color(hex: "#F472B6"),
                Color(hex: "#DB2777"),
                Color(hex: "#9D174D")
            ]
        }
    }

    func color(for level: Int, isDarkMode: Bool = true) -> Color {
        let palette = isDarkMode ? colors : lightModeColors
        let clampedLevel = min(max(level, 0), 4)
        return palette[clampedLevel]
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// App-wide theme colors
extension Color {
    static let gridBackground = Color(hex: "#0D1117")
    static let cardBackground = Color(hex: "#161B22")
    static let primaryText = Color(hex: "#C9D1D9")
    static let secondaryText = Color(hex: "#8B949E")
    static let accentGreen = Color(hex: "#39D353")
    static let borderColor = Color(hex: "#30363D")
}
