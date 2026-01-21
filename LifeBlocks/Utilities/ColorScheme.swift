import SwiftUI
import UIKit

// GitHub-style contribution colors
enum GridColorScheme: String, CaseIterable {
    case green = "green"      // iMessage Green
    case skyblue = "skyblue"  // Sky Blue
    case lavender = "lavender" // Lavender
    case blue = "blue"        // Ocean
    case purple = "purple"    // Violet
    case orange = "orange"    // Fire
    case pink = "pink"        // Rose

    var colors: [Color] {
        switch self {
        case .green:
            // iMessage-style green (#34C759)
            return [
                Color(hex: "#161B22"),  // Level 0 - Empty (dark mode bg)
                Color(hex: "#0D3D1F"),  // Level 1 - Light
                Color(hex: "#1A7A3E"),  // Level 2 - Medium
                Color(hex: "#28A745"),  // Level 3 - High
                Color(hex: "#34C759")   // Level 4 - Maximum (iMessage green)
            ]
        case .skyblue:
            // Sky Blue theme
            return [
                Color(hex: "#161B22"),
                Color(hex: "#0C3A5A"),  // Level 1
                Color(hex: "#1877B8"),  // Level 2
                Color(hex: "#3DA5E0"),  // Level 3
                Color(hex: "#5AC8FA")   // Level 4 - iOS Sky Blue
            ]
        case .lavender:
            // Lavender theme
            return [
                Color(hex: "#161B22"),
                Color(hex: "#3D2E5C"),  // Level 1
                Color(hex: "#6B5B95"),  // Level 2
                Color(hex: "#9B8DC2"),  // Level 3
                Color(hex: "#BDB5D5")   // Level 4 - Soft Lavender
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

    /// The accent color for this theme (used for buttons, highlights, etc.)
    var accentColor: Color {
        colors[4]  // Use the brightest color as accent
    }

    var lightModeColors: [Color] {
        switch self {
        case .green:
            // iMessage green for light mode
            return [
                Color(hex: "#EBEDF0"),  // Level 0 - Empty
                Color(hex: "#A8E6CF"),  // Level 1 - Light
                Color(hex: "#5DD39E"),  // Level 2 - Medium
                Color(hex: "#34C759"),  // Level 3 - High
                Color(hex: "#248A3D")   // Level 4 - Maximum
            ]
        case .skyblue:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#B3E0F2"),  // Level 1
                Color(hex: "#7CC5E3"),  // Level 2
                Color(hex: "#5AC8FA"),  // Level 3
                Color(hex: "#0A84FF")   // Level 4
            ]
        case .lavender:
            return [
                Color(hex: "#EBEDF0"),
                Color(hex: "#E2D9F3"),  // Level 1
                Color(hex: "#BDB5D5"),  // Level 2
                Color(hex: "#9B8DC2"),  // Level 3
                Color(hex: "#6B5B95")   // Level 4
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

// App-wide theme colors - WCAG AA compliant contrast in both light and dark modes
// IMPORTANT: These override asset catalog colors to guarantee readability

extension Color {
    // Text colors - HIGH CONTRAST for readability in all conditions
    static let primaryText = Color.primary  // System primary - adapts automatically
    static let inputText = Color.primary  // Uses system for best contrast

    // MARK: - Secondary Text - VERY BRIGHT for readability
    // Dark mode: Near-white (#E8ECF0), Light mode: Dark gray (#3D4752)
    static var secondaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.91, green: 0.93, blue: 0.94, alpha: 1.0)  // #E8ECF0 - very bright
                : UIColor(red: 0.24, green: 0.28, blue: 0.32, alpha: 1.0)  // #3D4752 - dark
        })
    }

    // MARK: - Tertiary Text - Still readable
    // Dark mode: Light gray (#D0D7DE), Light mode: Medium gray (#57606A)
    static var tertiaryText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.82, green: 0.84, blue: 0.87, alpha: 1.0)  // #D0D7DE
                : UIColor(red: 0.34, green: 0.38, blue: 0.42, alpha: 1.0)  // #57606A
        })
    }

    // MARK: - Placeholder Text
    // Dark mode: #B8C0C8, Light mode: #6B7280
    static var placeholderText: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.72, green: 0.75, blue: 0.78, alpha: 1.0)  // #B8C0C8
                : UIColor(red: 0.42, green: 0.45, blue: 0.50, alpha: 1.0)  // #6B7280
        })
    }

    // MARK: - Backgrounds
    static var gridBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1.0)  // #0D1117
                : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)  // #F6F8FA
        })
    }

    static var cardBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1.0)  // #161B22
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)     // #FFFFFF
        })
    }

    static var cardBackgroundLight: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.13, green: 0.16, blue: 0.19, alpha: 1.0)  // #21262D
                : UIColor(red: 0.98, green: 0.98, blue: 0.99, alpha: 1.0)  // #FAFBFC
        })
    }

    // MARK: - Border
    static var borderColor: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.24, green: 0.27, blue: 0.30, alpha: 1.0)  // #3D444D
                : UIColor(red: 0.78, green: 0.82, blue: 0.85, alpha: 1.0)  // #C8D0D8
        })
    }

    // Accent colors
    static let accentGreen = Color(hex: "#34C759")      // iMessage green
    static let accentSkyBlue = Color(hex: "#5AC8FA")    // iOS Sky Blue
    static let accentLavender = Color(hex: "#BDB5D5")   // Soft Lavender
}

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: GridColorScheme = .green

    private init() {
        // Load saved theme
        if let themeName = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = GridColorScheme(rawValue: themeName) {
            currentTheme = theme
        }
    }

    var accentColor: Color {
        currentTheme.accentColor
    }

    func setTheme(_ theme: GridColorScheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }
}

// MARK: - Text Field Styling

struct BrightTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundStyle(Color.inputText)
            .padding(12)
            .background(Color.cardBackgroundLight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.borderColor, lineWidth: 1)
            )
    }
}

extension View {
    func brightTextFieldStyle() -> some View {
        self.textFieldStyle(BrightTextFieldStyle())
    }
}
