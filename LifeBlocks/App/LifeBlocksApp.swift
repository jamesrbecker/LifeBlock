import SwiftUI
import SwiftData

@main
struct LifeBlocksApp: App {
    @State private var hasCompletedOnboarding = AppSettings.shared.hasCompletedOnboarding
    @AppStorage("colorSchemeOverride", store: UserDefaults(suiteName: "group.com.lifeblock.app")) private var colorSchemeOverride: String?

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
    }

    private var colorSchemePreference: ColorScheme? {
        switch colorSchemeOverride {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    private func configureAppearance() {
        // Configure global UI appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.gridBackground)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance

        // Tab bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(Color.cardBackground)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
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
        .tint(.accentGreen)
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
