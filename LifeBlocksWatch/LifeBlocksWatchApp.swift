import SwiftUI
import WatchConnectivity

@main
struct LifeBlocksWatchApp: App {
    @StateObject private var connectivity = WatchConnectivityManager.shared

    var body: some Scene {
        WindowGroup {
            WatchContentView()
                .environmentObject(connectivity)
        }
    }
}
