import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()

    @Published var habits: [WatchHabit] = []
    @Published var currentStreak: Int = 0
    @Published var checkedInToday: Bool = false
    @Published var isConnected: Bool = false

    private var session: WCSession?

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        // Load cached data from UserDefaults
        loadCachedData()
    }

    // MARK: - Data Sync

    func requestSync() {
        guard let session = session, session.isReachable else { return }

        session.sendMessage(["action": "sync"], replyHandler: { response in
            DispatchQueue.main.async {
                self.handleSyncResponse(response)
            }
        }, errorHandler: { error in
            print("Sync error: \(error.localizedDescription)")
        })
    }

    func sendCheckIn(habitId: UUID, completed: Bool) {
        guard let session = session, session.isReachable else {
            // Queue for later sync
            queueOfflineCheckIn(habitId: habitId, completed: completed)
            return
        }

        let message: [String: Any] = [
            "action": "checkIn",
            "habitId": habitId.uuidString,
            "completed": completed,
            "timestamp": Date().timeIntervalSince1970
        ]

        session.sendMessage(message, replyHandler: { response in
            DispatchQueue.main.async {
                if let success = response["success"] as? Bool, success {
                    self.updateLocalHabitStatus(habitId: habitId, completed: completed)
                }
            }
        }, errorHandler: { error in
            print("Check-in error: \(error.localizedDescription)")
            self.queueOfflineCheckIn(habitId: habitId, completed: completed)
        })
    }

    // MARK: - Private Helpers

    private func handleSyncResponse(_ response: [String: Any]) {
        if let habitsData = response["habits"] as? [[String: Any]] {
            habits = habitsData.compactMap { WatchHabit(from: $0) }
        }

        if let streak = response["streak"] as? Int {
            currentStreak = streak
        }

        if let checkedIn = response["checkedInToday"] as? Bool {
            checkedInToday = checkedIn
        }

        cacheData()
    }

    private func updateLocalHabitStatus(habitId: UUID, completed: Bool) {
        if let index = habits.firstIndex(where: { $0.id == habitId }) {
            habits[index].isCompletedToday = completed
        }

        // Check if all habits are completed
        checkedInToday = habits.allSatisfy { $0.isCompletedToday }
        cacheData()
    }

    private func queueOfflineCheckIn(habitId: UUID, completed: Bool) {
        var queue = UserDefaults.standard.array(forKey: "offlineCheckIns") as? [[String: Any]] ?? []
        queue.append([
            "habitId": habitId.uuidString,
            "completed": completed,
            "timestamp": Date().timeIntervalSince1970
        ])
        UserDefaults.standard.set(queue, forKey: "offlineCheckIns")

        // Update local state optimistically
        updateLocalHabitStatus(habitId: habitId, completed: completed)
    }

    private func syncOfflineCheckIns() {
        guard let session = session, session.isReachable else { return }
        guard let queue = UserDefaults.standard.array(forKey: "offlineCheckIns") as? [[String: Any]], !queue.isEmpty else { return }

        let message: [String: Any] = [
            "action": "batchCheckIn",
            "checkIns": queue
        ]

        session.sendMessage(message, replyHandler: { response in
            if let success = response["success"] as? Bool, success {
                UserDefaults.standard.removeObject(forKey: "offlineCheckIns")
            }
        }, errorHandler: nil)
    }

    private func cacheData() {
        let habitsData = habits.map { $0.toDictionary() }
        UserDefaults.standard.set(habitsData, forKey: "cachedHabits")
        UserDefaults.standard.set(currentStreak, forKey: "cachedStreak")
        UserDefaults.standard.set(checkedInToday, forKey: "cachedCheckedIn")
    }

    private func loadCachedData() {
        if let habitsData = UserDefaults.standard.array(forKey: "cachedHabits") as? [[String: Any]] {
            habits = habitsData.compactMap { WatchHabit(from: $0) }
        }
        currentStreak = UserDefaults.standard.integer(forKey: "cachedStreak")
        checkedInToday = UserDefaults.standard.bool(forKey: "cachedCheckedIn")
    }
}

// MARK: - WCSessionDelegate

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isConnected = activationState == .activated
            if self.isConnected {
                self.requestSync()
                self.syncOfflineCheckIns()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
            if session.isReachable {
                self.syncOfflineCheckIns()
            }
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if message["action"] as? String == "update" {
                self.handleSyncResponse(message)
            }
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async {
            self.handleSyncResponse(applicationContext)
        }
    }
}

// MARK: - WatchHabit Model

struct WatchHabit: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    var isCompletedToday: Bool

    init?(from dict: [String: Any]) {
        guard let idString = dict["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = dict["name"] as? String,
              let icon = dict["icon"] as? String,
              let colorHex = dict["colorHex"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isCompletedToday = dict["completed"] as? Bool ?? false
    }

    func toDictionary() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "icon": icon,
            "colorHex": colorHex,
            "completed": isCompletedToday
        ]
    }
}
