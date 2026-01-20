import SwiftUI

// MARK: - Icon Picker View
/// Full SF Symbols browser for custom habit icons

struct IconPickerView: View {
    @Binding var selectedIcon: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: IconCategory = .all

    enum IconCategory: String, CaseIterable {
        case all = "All"
        case fitness = "Fitness"
        case productivity = "Productivity"
        case health = "Health"
        case finance = "Finance"
        case creative = "Creative"
        case social = "Social"
        case nature = "Nature"
        case misc = "Misc"

        var icons: [String] {
            switch self {
            case .all:
                return IconCategory.allCases.filter { $0 != .all }.flatMap { $0.icons }
            case .fitness:
                return [
                    "figure.run", "figure.walk", "figure.yoga", "figure.strengthtraining.traditional",
                    "figure.hiking", "figure.swimming", "figure.basketball", "figure.tennis",
                    "figure.golf", "figure.boxing", "figure.dance", "figure.climbing",
                    "figure.skiing.downhill", "figure.surfing", "dumbbell.fill", "sportscourt.fill",
                    "bicycle", "figure.cooldown", "figure.core.training", "figure.flexibility"
                ]
            case .productivity:
                return [
                    "briefcase.fill", "laptopcomputer", "desktopcomputer", "keyboard.fill",
                    "doc.text.fill", "folder.fill", "tray.full.fill", "archivebox.fill",
                    "calendar", "clock.fill", "timer", "hourglass",
                    "checklist", "list.bullet", "chart.bar.fill", "chart.line.uptrend.xyaxis",
                    "target", "flag.fill", "pin.fill", "bookmark.fill"
                ]
            case .health:
                return [
                    "heart.fill", "heart.circle.fill", "brain.head.profile", "lungs.fill",
                    "pills.fill", "cross.case.fill", "stethoscope", "bandage.fill",
                    "bed.double.fill", "moon.fill", "sun.max.fill", "drop.fill",
                    "leaf.fill", "carrot.fill", "fork.knife", "cup.and.saucer.fill"
                ]
            case .finance:
                return [
                    "dollarsign.circle.fill", "banknote.fill", "creditcard.fill", "wallet.pass.fill",
                    "chart.pie.fill", "chart.xyaxis.line", "building.columns.fill", "percent",
                    "arrow.up.right.circle.fill", "arrow.down.right.circle.fill", "bag.fill", "cart.fill",
                    "gift.fill", "tag.fill", "barcode", "qrcode"
                ]
            case .creative:
                return [
                    "paintbrush.fill", "paintpalette.fill", "pencil.tip", "pencil.and.outline",
                    "camera.fill", "video.fill", "music.note", "music.note.list",
                    "guitars.fill", "pianokeys", "headphones", "mic.fill",
                    "theatermasks.fill", "film.fill", "photo.fill", "rectangle.stack.fill"
                ]
            case .social:
                return [
                    "person.fill", "person.2.fill", "person.3.fill", "figure.and.child.holdinghands",
                    "bubble.left.fill", "bubble.left.and.bubble.right.fill", "phone.fill", "video.circle.fill",
                    "envelope.fill", "hand.wave.fill", "hand.thumbsup.fill", "heart.text.square.fill",
                    "gift.fill", "party.popper.fill", "balloon.fill", "birthday.cake.fill"
                ]
            case .nature:
                return [
                    "leaf.fill", "tree.fill", "mountain.2.fill", "water.waves",
                    "sun.max.fill", "moon.stars.fill", "cloud.fill", "snowflake",
                    "flame.fill", "wind", "tornado", "rainbow",
                    "pawprint.fill", "bird.fill", "fish.fill", "ant.fill"
                ]
            case .misc:
                return [
                    "star.fill", "sparkles", "bolt.fill", "lightbulb.fill",
                    "globe", "airplane", "car.fill", "bus.fill",
                    "house.fill", "building.2.fill", "gamecontroller.fill", "puzzlepiece.fill",
                    "book.fill", "graduationcap.fill", "newspaper.fill", "megaphone.fill"
                ]
            }
        }
    }

    var filteredIcons: [String] {
        let categoryIcons = selectedCategory.icons
        if searchText.isEmpty {
            return categoryIcons
        }
        return categoryIcons.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category Picker
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(IconCategory.allCases, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category.rawValue)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundStyle(selectedCategory == category ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)

                // Icon Grid
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(filteredIcons, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                                dismiss()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedIcon == icon ? Color.green : Color.gray.opacity(0.1))
                                        .frame(height: 50)

                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(selectedIcon == icon ? .white : .primary)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Search icons")
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Icon Button (for use in forms)

struct IconPickerButton: View {
    @Binding var selectedIcon: String
    @State private var showingPicker = false

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack {
                Text("Icon")
                Spacer()
                Image(systemName: selectedIcon)
                    .font(.title2)
                    .foregroundStyle(.green)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
    }
}

// MARK: - Color Picker Button

struct ColorPickerButton: View {
    @Binding var selectedColor: String
    @State private var showingPicker = false

    let colors: [String] = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DDA0DD",
        "#FF9FF3", "#54A0FF", "#5F27CD", "#00D2D3", "#FF9F43", "#10AC84",
        "#EE5A24", "#0984E3", "#6C5CE7", "#00B894", "#E17055", "#74B9FF"
    ]

    var body: some View {
        Button {
            showingPicker = true
        } label: {
            HStack {
                Text("Color")
                Spacer()
                Circle()
                    .fill(Color(hex: selectedColor))
                    .frame(width: 30, height: 30)
            }
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingPicker) {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Button {
                                selectedColor = color
                                showingPicker = false
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: color))
                                        .frame(width: 44, height: 44)

                                    if selectedColor == color {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.white)
                                            .fontWeight(.bold)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Choose Color")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showingPicker = false
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    IconPickerView(selectedIcon: .constant("star.fill"))
        .preferredColorScheme(.dark)
}
