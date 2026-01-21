import Foundation
import CloudKit

// MARK: - Leaderboard Entry

struct LeaderboardEntry: Identifiable, Equatable {
    let id: String
    let userID: String
    let displayName: String
    let avatarEmoji: String
    let currentStreak: Int
    let longestStreak: Int
    let weeklyScore: Int
    let monthlyScore: Int
    let lifetimeScore: Int
    let consistencyPercent: Double
    let accountCreatedAt: Date
    let lastUpdated: Date

    var rank: Int = 0

    // Check if entry passes sanity checks
    func isValid(appReleaseDate: Date = LeaderboardService.appReleaseDate) -> Bool {
        let accountAgeDays = Calendar.current.dateComponents([.day], from: accountCreatedAt, to: Date()).day ?? 0
        let daysSinceRelease = Calendar.current.dateComponents([.day], from: appReleaseDate, to: Date()).day ?? 0

        // Streak can't exceed account age
        guard currentStreak <= accountAgeDays else { return false }

        // Streak can't exceed days since app release
        guard currentStreak <= daysSinceRelease else { return false }

        // Account must be at least 1 day old
        guard accountAgeDays >= 1 else { return false }

        // Reasonable streak cap (no 10-year streaks)
        guard currentStreak <= 3650 else { return false }

        return true
    }
}

// MARK: - Leaderboard Type

enum LeaderboardType: String, CaseIterable {
    case streak = "Streak"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case allTime = "All Time"

    var icon: String {
        switch self {
        case .streak: return "flame.fill"
        case .weekly: return "calendar"
        case .monthly: return "calendar.badge.clock"
        case .allTime: return "trophy.fill"
        }
    }

    var sortKey: String {
        switch self {
        case .streak: return "currentStreak"
        case .weekly: return "weeklyScore"
        case .monthly: return "monthlyScore"
        case .allTime: return "lifetimeScore"
        }
    }
}

// MARK: - Leaderboard Scope

enum LeaderboardScope: String, CaseIterable {
    case friends = "Friends"
    case global = "Global"

    var icon: String {
        switch self {
        case .friends: return "person.2.fill"
        case .global: return "globe"
        }
    }
}

// MARK: - Leaderboard Service

@MainActor
final class LeaderboardService: ObservableObject {
    static let shared = LeaderboardService()

    // App release date for sanity checks
    static let appReleaseDate = Date(timeIntervalSince1970: 1737331200) // Jan 20, 2025

    private let container: CKContainer
    private let publicDB: CKDatabase

    @Published var globalEntries: [LeaderboardEntry] = []
    @Published var friendEntries: [LeaderboardEntry] = []
    @Published var currentUserEntry: LeaderboardEntry?
    @Published var currentUserRank: Int?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isOptedIntoGlobal: Bool = false

    private init() {
        container = CKContainer(identifier: "iCloud.com.lifeblock.app")
        publicDB = container.publicCloudDatabase

        isOptedIntoGlobal = UserDefaults.standard.bool(forKey: "leaderboard.optedIntoGlobal")
    }

    // MARK: - Public Methods

    /// Fetch leaderboard entries
    func fetchLeaderboard(type: LeaderboardType, scope: LeaderboardScope) async {
        isLoading = true
        error = nil

        do {
            switch scope {
            case .global:
                try await fetchGlobalLeaderboard(type: type)
            case .friends:
                try await fetchFriendsLeaderboard(type: type)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Update current user's leaderboard entry
    func updateCurrentUserEntry() async {
        guard isOptedIntoGlobal else { return }

        let settings = AppSettings.shared
        let entry = createEntryFromSettings()

        // Validate before submitting
        guard entry.isValid() else {
            print("Entry failed sanity check, not submitting")
            return
        }

        do {
            try await saveEntryToCloud(entry)
            currentUserEntry = entry
        } catch {
            print("Failed to update leaderboard entry: \(error)")
        }
    }

    /// Opt in/out of global leaderboard
    func setGlobalOptIn(_ optIn: Bool) async {
        isOptedIntoGlobal = optIn
        UserDefaults.standard.set(optIn, forKey: "leaderboard.optedIntoGlobal")

        if optIn {
            await updateCurrentUserEntry()
        } else {
            await removeFromGlobalLeaderboard()
        }
    }

    // MARK: - Private Methods

    private func fetchGlobalLeaderboard(type: LeaderboardType) async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "LeaderboardEntry", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: type.sortKey, ascending: false)]

        let (results, _) = try await publicDB.records(matching: query, resultsLimit: 100)

        var entries: [LeaderboardEntry] = []
        let currentUserID = AppSettings.shared.userID

        for (_, result) in results {
            if case .success(let record) = result {
                if let entry = LeaderboardEntry(from: record), entry.isValid() {
                    entries.append(entry)
                }
            }
        }

        // Assign ranks
        for (index, var entry) in entries.enumerated() {
            entry.rank = index + 1
            entries[index] = entry

            if entry.userID == currentUserID {
                currentUserEntry = entry
                currentUserRank = entry.rank
            }
        }

        globalEntries = entries
    }

    private func fetchFriendsLeaderboard(type: LeaderboardType) async throws {
        // For friends, we use locally stored friend data
        // This would sync via CloudKit in a full implementation

        var entries: [LeaderboardEntry] = []

        // Add current user
        let currentEntry = createEntryFromSettings()
        entries.append(currentEntry)

        // In a real implementation, we'd fetch friend entries from CloudKit
        // For now, this uses the local Friend model data

        // Sort by the selected type
        switch type {
        case .streak:
            entries.sort { $0.currentStreak > $1.currentStreak }
        case .weekly:
            entries.sort { $0.weeklyScore > $1.weeklyScore }
        case .monthly:
            entries.sort { $0.monthlyScore > $1.monthlyScore }
        case .allTime:
            entries.sort { $0.lifetimeScore > $1.lifetimeScore }
        }

        // Assign ranks
        for (index, var entry) in entries.enumerated() {
            entry.rank = index + 1
            entries[index] = entry
        }

        friendEntries = entries

        if let userEntry = entries.first(where: { $0.userID == AppSettings.shared.userID }) {
            currentUserEntry = userEntry
            currentUserRank = userEntry.rank
        }
    }

    private func createEntryFromSettings() -> LeaderboardEntry {
        let settings = AppSettings.shared

        // Calculate consistency percent (check-ins / days since first check-in)
        let daysSinceStart = max(1, Calendar.current.dateComponents(
            [.day],
            from: settings.pathStartDate ?? Date(),
            to: Date()
        ).day ?? 1)

        let consistency = min(100, Double(settings.totalCheckIns) / Double(daysSinceStart) * 100)

        return LeaderboardEntry(
            id: settings.userID,
            userID: settings.userID,
            displayName: settings.displayName,
            avatarEmoji: settings.avatarEmoji,
            currentStreak: settings.currentStreak,
            longestStreak: settings.longestStreak,
            weeklyScore: settings.weeklyScore,
            monthlyScore: calculateMonthlyScore(),
            lifetimeScore: settings.totalCheckIns * 2, // Simple scoring
            consistencyPercent: consistency,
            accountCreatedAt: settings.pathStartDate ?? Date(),
            lastUpdated: Date()
        )
    }

    private func calculateMonthlyScore() -> Int {
        // Would calculate from actual data - simplified here
        return AppSettings.shared.weeklyScore * 4
    }

    private func saveEntryToCloud(_ entry: LeaderboardEntry) async throws {
        let record = CKRecord(recordType: "LeaderboardEntry", recordID: CKRecord.ID(recordName: entry.userID))

        record["userID"] = entry.userID
        record["displayName"] = entry.displayName
        record["avatarEmoji"] = entry.avatarEmoji
        record["currentStreak"] = entry.currentStreak
        record["longestStreak"] = entry.longestStreak
        record["weeklyScore"] = entry.weeklyScore
        record["monthlyScore"] = entry.monthlyScore
        record["lifetimeScore"] = entry.lifetimeScore
        record["consistencyPercent"] = entry.consistencyPercent
        record["accountCreatedAt"] = entry.accountCreatedAt
        record["lastUpdated"] = entry.lastUpdated

        _ = try await publicDB.save(record)
    }

    private func removeFromGlobalLeaderboard() async {
        let recordID = CKRecord.ID(recordName: AppSettings.shared.userID)

        do {
            try await publicDB.deleteRecord(withID: recordID)
        } catch {
            print("Failed to remove from leaderboard: \(error)")
        }
    }
}

// MARK: - LeaderboardEntry CloudKit Extension

extension LeaderboardEntry {
    init?(from record: CKRecord) {
        guard
            let userID = record["userID"] as? String,
            let displayName = record["displayName"] as? String
        else {
            return nil
        }

        self.id = record.recordID.recordName
        self.userID = userID
        self.displayName = displayName
        self.avatarEmoji = record["avatarEmoji"] as? String ?? "😀"
        self.currentStreak = record["currentStreak"] as? Int ?? 0
        self.longestStreak = record["longestStreak"] as? Int ?? 0
        self.weeklyScore = record["weeklyScore"] as? Int ?? 0
        self.monthlyScore = record["monthlyScore"] as? Int ?? 0
        self.lifetimeScore = record["lifetimeScore"] as? Int ?? 0
        self.consistencyPercent = record["consistencyPercent"] as? Double ?? 0
        self.accountCreatedAt = record["accountCreatedAt"] as? Date ?? Date()
        self.lastUpdated = record["lastUpdated"] as? Date ?? Date()
    }
}
