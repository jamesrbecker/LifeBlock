import SwiftUI

struct DaySquareView: View {
    let date: Date
    let level: Int
    let colorScheme: GridColorScheme
    let size: CGFloat
    let cornerRadius: CGFloat
    let isSelected: Bool

    @Environment(\.colorScheme) private var systemColorScheme

    init(
        date: Date,
        level: Int,
        colorScheme: GridColorScheme = .green,
        size: CGFloat = 12,
        cornerRadius: CGFloat = 2,
        isSelected: Bool = false
    ) {
        self.date = date
        self.level = level
        self.colorScheme = colorScheme
        self.size = size
        self.cornerRadius = cornerRadius
        self.isSelected = isSelected
    }

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(colorScheme.color(for: level, isDarkMode: isDarkMode))
            .frame(width: size, height: size)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white, lineWidth: 2)
                }
            }
            .overlay {
                if date.isToday {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
            }
    }
}

// Larger version for widget and detail views
struct DaySquareLargeView: View {
    let date: Date
    let level: Int
    let colorScheme: GridColorScheme
    let showDate: Bool

    @Environment(\.colorScheme) private var systemColorScheme

    init(
        date: Date,
        level: Int,
        colorScheme: GridColorScheme = .green,
        showDate: Bool = false
    ) {
        self.date = date
        self.level = level
        self.colorScheme = colorScheme
        self.showDate = showDate
    }

    private var isDarkMode: Bool {
        systemColorScheme == .dark
    }

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .fill(colorScheme.color(for: level, isDarkMode: isDarkMode))
                .frame(width: 32, height: 32)
                .overlay {
                    if date.isToday {
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Color.white, lineWidth: 2)
                    }
                }

            if showDate {
                Text(dayNumber)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// Preview
#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 4) {
            ForEach(0..<5) { level in
                DaySquareView(
                    date: Date(),
                    level: level,
                    colorScheme: .green,
                    size: 20
                )
            }
        }

        HStack(spacing: 4) {
            ForEach(0..<5) { level in
                DaySquareLargeView(
                    date: DateHelpers.daysAgo(level),
                    level: level,
                    showDate: true
                )
            }
        }
    }
    .padding()
    .background(Color.gridBackground)
}
