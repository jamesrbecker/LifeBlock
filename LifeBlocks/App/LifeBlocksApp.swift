import SwiftUI
import SwiftData

@main
struct LifeBlocksApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var hasCompletedOnboarding = AppSettings.shared.hasCompletedOnboarding
    @AppStorage("colorSchemeOverride", store: UserDefaults(suiteName: "group.com.lifeblock.app")) private var colorSchemeOverride: String?
    @Environment(\.scenePhase) private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitCompletion.self,
            DayEntry.self,
            UserSettings.self,
            Friend.self,
            FriendRequest.self,
            Cheer.self,
            Challenge.self
        ])

        // Disable CloudKit sync to avoid non-optional attribute issues
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.lifeblock.app"),
            cloudKitDatabase: .none  // Explicitly disable CloudKit
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If loading fails, try to delete corrupted store and recreate
            print("Failed to create ModelContainer: \(error)")
            print("Attempting to recreate database...")

            // Try without group container as fallback
            let fallbackConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
            )

            do {
                return try ModelContainer(for: schema, configurations: [fallbackConfig])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    AdaptiveRootView()
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                }
            }
            .onAppear {
                configureAppearance()
                configureManagers()
            }
            .preferredColorScheme(colorSchemePreference)
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Clear notification badge when app becomes active
                clearNotificationBadge()
            }
        }
    }

    private func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
        // Also remove delivered notifications from notification center
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    private var colorSchemePreference: ColorScheme? {
        switch colorSchemeOverride {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private func configureAppearance() {
        // Configure global UI appearance with adaptive colors
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Use adaptive colors that work in both light and dark mode
        appearance.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.05, green: 0.07, blue: 0.09, alpha: 1.0)  // #0D1117
                : UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)  // #F6F8FA
        }

        let titleColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor.white
                : UIColor.black
        }
        appearance.titleTextAttributes = [.foregroundColor: titleColor]
        appearance.largeTitleTextAttributes = [.foregroundColor: titleColor]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Tab bar with adaptive colors
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1.0)  // #161B22
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)     // #FFFFFF
        }

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance

        // Set global tint color for text cursor (sky blue)
        UITextField.appearance().tintColor = UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0)  // #5AC8FA
        UITextView.appearance().tintColor = UIColor(red: 0.35, green: 0.78, blue: 0.98, alpha: 1.0)  // #5AC8FA
    }

    private func configureManagers() {
        // Configure data manager
        DataManager.shared.configure(with: sharedModelContainer.mainContext)

        // Register notification categories
        NotificationManager.shared.registerNotificationCategories()
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Label("Grid", systemImage: "square.grid.3x3.fill")
                }
                .tag(0)

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)

            FriendsView()
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                .tag(2)

            HabitListView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .tint(.accentSkyBlue)
    }
}

// MARK: - App Delegate for Notification Handling

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    // Handle notification action
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        switch response.actionIdentifier {
        case "CHECK_IN":
            // Navigate to check-in via deep link
            if let url = URL(string: "lifeblock://checkin") {
                UIApplication.shared.open(url)
            }

        case "SNOOZE":
            // Reschedule notification for 1 hour
            Task { @MainActor in
                let snoozeTime = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
                await NotificationManager.shared.scheduleDailyReminder(at: snoozeTime)
            }

        default:
            break
        }

        completionHandler()
    }
}
