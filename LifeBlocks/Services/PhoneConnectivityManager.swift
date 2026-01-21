import Foundation
import WatchConnectivity
import SwiftData

@MainActor
class PhoneConnectivityManager: NSObject, ObservableObject {
    static let shared = PhoneConnectivityManager()

    @Published var isWatchConnected: Bool = false
    @Published var isWatchAppInstalled: Bool = false

    private var session: WCSession?
    private var modelContext: ModelContext?

    override init() {
        super.init()

        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func configure(with context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Send Updates to Watch

    func sendUpdateToWatch() {
        guard let session = session, session.isPaired, session.isWatchAppInstalled else { return }

        let updateData = buildSyncData()

        if session.isReachable {
            var message = updateData
            message["action"] = "update"
            session.sendMessage(message, replyHandler: nil, errorHandler: nil)
        } else {
            try? session.updateApplicationContext(updateData)
        }
    }

    private func buildSyncData() -> [String: Any] {
        var data: [String: Any] = [:]

        // Get habits
        if let context = modelContext {
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate { $0.isActive },
                sortBy: [SortDescriptor(\Habit.sortOrder)]
            )

            if let habits = try? context.fetch(descriptor) {
                let today = Date()
                data["habits"] = habits.map { habit -> [String: Any] in
                    // Check if habit is completed today
                    let isCompleted = habit.completions?.contains { completion in
                        Calendar.current.isDate(completion.date, inSameDayAs: today)
                    } ?? false

                    return [
                        "id": habit.id.uuidString,
                        "name": habit.name,
                        "icon": habit.icon,
                        "colorHex": habit.colorHex,
                        "completed": isCompleted
                    ]
                }
            }
        }

        // Get streak info
        data["streak"] = AppSettings.shared.currentStreak
        data["checkedInToday"] = hasCheckedInToday()

        return data
    }

    private func hasCheckedInToday() -> Bool {
        guard let context = modelContext else { return false }

        let today = Date()
        let descriptor = FetchDescriptor<DayEntry>(
            predicate: #Predicate { entry in
                entry.checkedIn
            }
        )

        if let entries = try? context.fetch(descriptor) {
            return entries.contains { Calendar.current.isDate($0.date, inSameDayAs: today) }
        }
        return false
    }

    // MARK: - Handle Watch Check-ins

    private func handleCheckIn(habitId: UUID, completed: Bool, timestamp: Date) {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Habit>(
            predicate: #Predicate { $0.isActive }
        )

        guard let habits = try? context.fetch(descriptor),
              let habit = habits.first(where: { $0.id == habitId }) else { return }

        if completed {
            // Add completion
            let completion = HabitCompletion(date: timestamp, completionLevel: 2)
            completion.habit = habit
            if habit.completions == nil {
                habit.completions = []
            }
            habit.completions?.append(completion)
            context.insert(completion)
        } else {
            // Remove completion for today
            if let completions = habit.completions {
                for completion in completions {
                    if Calendar.current.isDate(completion.date, inSameDayAs: timestamp) {
                        context.delete(completion)
                    }
                }
            }
        }

        try? context.save()

        // Update streak
        AppSettings.shared.updateStreak(checkedInToday: completed)

        // Send updated data back to watch
        sendUpdateToWatch()

        // Sync widget data
        DataManager.shared.syncWidgetData()
    }

    private func handleBatchCheckIn(checkIns: [[String: Any]]) {
        for checkIn in checkIns {
            guard let idString = checkIn["habitId"] as? String,
                  let habitId = UUID(uuidString: idString),
                  let completed = checkIn["completed"] as? Bool,
                  let timestamp = checkIn["timestamp"] as? TimeInterval else { continue }

            handleCheckIn(habitId: habitId, completed: completed, timestamp: Date(timeIntervalSince1970: timestamp))
        }
    }
}

// MARK: - WCSessionDelegate

extension PhoneConnectivityManager: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            self.isWatchConnected = activationState == .activated
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {
        Task { @MainActor in
            self.isWatchConnected = false
        }
    }

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            self.isWatchConnected = false
        }
        session.activate()
    }

    nonisolated func sessionWatchStateDidChange(_ session: WCSession) {
        Task { @MainActor in
            self.isWatchAppInstalled = session.isWatchAppInstalled
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            guard let action = message["action"] as? String else {
                replyHandler(["success": false])
                return
            }

            switch action {
            case "sync":
                let data = buildSyncData()
                replyHandler(data)

            case "checkIn":
                guard let idString = message["habitId"] as? String,
                      let habitId = UUID(uuidString: idString),
                      let completed = message["completed"] as? Bool,
                      let timestamp = message["timestamp"] as? TimeInterval else {
                    replyHandler(["success": false])
                    return
                }

                handleCheckIn(habitId: habitId, completed: completed, timestamp: Date(timeIntervalSince1970: timestamp))
                replyHandler(["success": true])

            case "batchCheckIn":
                guard let checkIns = message["checkIns"] as? [[String: Any]] else {
                    replyHandler(["success": false])
                    return
                }

                handleBatchCheckIn(checkIns: checkIns)
                replyHandler(["success": true])

            default:
                replyHandler(["success": false])
            }
        }
    }
}
