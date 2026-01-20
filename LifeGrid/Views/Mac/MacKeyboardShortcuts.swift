import SwiftUI

// MARK: - Mac Keyboard Shortcuts
/// Provides keyboard shortcuts for Mac Catalyst

struct MacKeyboardShortcuts: ViewModifier {
    @Binding var showingCheckIn: Bool
    @Binding var selectedTab: Int

    func body(content: Content) -> some View {
        content
            .keyboardShortcut("n", modifiers: [.command]) // New check-in
            .onReceive(NotificationCenter.default.publisher(for: .newCheckIn)) { _ in
                showingCheckIn = true
            }
    }
}

// MARK: - Keyboard Shortcut Commands

struct AppCommands: Commands {
    @Binding var showingCheckIn: Bool

    var body: some Commands {
        // File Menu
        CommandGroup(after: .newItem) {
            Button("New Check-in") {
                NotificationCenter.default.post(name: .newCheckIn, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command])
        }

        // View Menu
        CommandMenu("View") {
            Button("Grid") {
                NotificationCenter.default.post(name: .switchTab, object: 0)
            }
            .keyboardShortcut("1", modifiers: [.command])

            Button("Stats") {
                NotificationCenter.default.post(name: .switchTab, object: 1)
            }
            .keyboardShortcut("2", modifiers: [.command])

            Button("Friends") {
                NotificationCenter.default.post(name: .switchTab, object: 2)
            }
            .keyboardShortcut("3", modifiers: [.command])

            Button("Habits") {
                NotificationCenter.default.post(name: .switchTab, object: 3)
            }
            .keyboardShortcut("4", modifiers: [.command])

            Button("Settings") {
                NotificationCenter.default.post(name: .switchTab, object: 4)
            }
            .keyboardShortcut(",", modifiers: [.command])
        }

        // Help Menu addition
        CommandGroup(after: .help) {
            Button("LifeBlocks Website") {
                if let url = URL(string: "https://jamesrbecker.github.io/LifeBlock/") {
                    #if os(macOS) || targetEnvironment(macCatalyst)
                    UIApplication.shared.open(url)
                    #endif
                }
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let newCheckIn = Notification.Name("newCheckIn")
    static let switchTab = Notification.Name("switchTab")
}

// MARK: - Mac Menu Bar Extra (for future macOS native)

#if os(macOS)
struct MenuBarExtra: Scene {
    var body: some Scene {
        MenuBarExtra("LifeBlocks", systemImage: "square.grid.3x3.fill") {
            Button("Check In") {
                NotificationCenter.default.post(name: .newCheckIn, object: nil)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

            Button("Open LifeBlocks") {
                NSApp.activate(ignoringOtherApps: true)
            }

            Divider()

            Button("Quit") {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q", modifiers: [.command])
        }
    }
}
#endif

// MARK: - Mac Window Styling

struct MacWindowStyle: ViewModifier {
    func body(content: Content) -> some View {
        #if targetEnvironment(macCatalyst)
        content
            .onAppear {
                configureMacWindow()
            }
        #else
        content
        #endif
    }

    #if targetEnvironment(macCatalyst)
    private func configureMacWindow() {
        // Configure window for Mac
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.titlebar?.titleVisibility = .visible
            windowScene.titlebar?.toolbar = nil

            // Set minimum window size
            windowScene.sizeRestrictions?.minimumSize = CGSize(width: 800, height: 600)
            windowScene.sizeRestrictions?.maximumSize = CGSize(width: .infinity, height: .infinity)
        }
    }
    #endif
}

extension View {
    func macWindowStyle() -> some View {
        modifier(MacWindowStyle())
    }
}

// MARK: - Mac-Specific Toolbar

struct MacToolbar: ToolbarContent {
    @Binding var showingCheckIn: Bool

    var body: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingCheckIn = true
            } label: {
                Label("Check In", systemImage: "plus.circle.fill")
            }
            .keyboardShortcut("n", modifiers: [.command])
        }
        #endif
    }
}

// MARK: - Preview

#Preview {
    Text("Mac Keyboard Shortcuts")
        .frame(width: 400, height: 300)
}
