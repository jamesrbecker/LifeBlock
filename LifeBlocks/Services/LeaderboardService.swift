import Foundation
import CloudKit

// =============================================================================
// MARK: - LeaderboardService.swift
// =============================================================================
/// This file handles all leaderboard functionality for LifeBlocks.
///
/// ## Overview
/// The leaderboard system allows users to compete with others based on their
/// habit-tracking consistency. Users can opt-in to share their stats publicly.
///
/// ## Leaderboard Types
/// - **Global**: Platform-wide leaderboard with all opted-in users
/// - **My Path**: Filtered leaderboard showing only users on the same life path
///   (e.g., Software Engineers compete with other Software Engineers)
/// - **Friends**: Personal leaderboard with added friends
///
/// ## Ranking Metrics
/// - **Streak**: Current consecutive days of check-ins
/// - **Weekly**: Points earned this week
/// - **Monthly**: Points earned this month
/// - **All Time**: Total lifetime score
///
/// ## CloudKit Integration
/// All leaderboard data is stored in CloudKit's public database, allowing
/// users to see each other's stats while keeping habit details private.
///
/// ## Privacy
/// - Users must explicitly opt-in to appear on global leaderboards
/// - Only display name, avatar, and scores are shared
/// - Actual habit names and check-in times are NEVER shared

// =============================================================================
// MARK: - LeaderboardEntry
// =============================================================================
/// Represents a single user's entry on the leaderboard.
///
/// This struct contains all the publicly-visible stats for a user who has
/// opted into the leaderboard. The data is stored in CloudKit and fetched
/// when users view the leaderboard.

struct LeaderboardEntry: Identifiable, Equatable {

    /// Unique identifier for this entry (matches the CloudKit record ID)
    let id: String

    /// The user's unique ID (used to identify if this is the current user)
    let userID: String

    /// The name shown on the leaderboard (user-configurable)
    let displayName: String

    /// The emoji shown as the user's avatar (user-configurable)
    let avatarEmoji: String

    /// The user's current streak (consecutive days of check-ins)
    let currentStreak: Int

    /// The user's longest streak ever achieved
    let longestStreak: Int

    /// Points earned this week (resets every Monday)
    let weeklyScore: Int

    /// Points earned this month (resets on the 1st)
    let monthlyScore: Int

    /// Total points earned since account creation
    let lifetimeScore: Int

    /// Percentage of days with check-ins since account creation (0-100)
    let consistencyPercent: Double

    /// When the user created their account (used for sanity checks)
    let accountCreatedAt: Date

    /// When this entry was last updated in CloudKit
    let lastUpdated: Date

    /// The user's selected life path (e.g., "softwareEngineer", "student")
    /// Used to filter path-specific leaderboards
    /// Nil if user is in exploration mode or hasn't selected a path
    let lifePath: String?

    /// The user's short bio (premium feature, max 80 chars)
    let bio: String?

    /// The user's unique 6-character friend code for adding friends
    /// Format: 6 alphanumeric characters (e.g., "ABC123")
    let friendCode: String?

    /// The user's position on the leaderboard (assigned after sorting)
    /// This is calculated when displaying, not stored in CloudKit
    var rank: Int = 0

    // MARK: - Validation

    /// Validates that this leaderboard entry is legitimate and not cheated.
    ///
    /// This function performs several sanity checks to prevent fake entries:
    /// 1. Streak can't be longer than the account has existed
    /// 2. Streak can't be longer than the app has been released
    /// 3. Account must be at least 1 day old
    /// 4. Streak can't exceed 10 years (reasonable maximum)
    ///
    /// - Parameter appReleaseDate: The date the app was released (default: Jan 20, 2025)
    /// - Returns: `true` if the entry passes all sanity checks, `false` otherwise
    func isValid(appReleaseDate: Date = LeaderboardService.appReleaseDate) -> Bool {
        // Calculate how many days since the account was created
        let accountAgeDays = Calendar.current.dateComponents([.day], from: accountCreatedAt, to: Date()).day ?? 0

        // Calculate how many days since the app was released
        let daysSinceRelease = Calendar.current.dateComponents([.day], from: appReleaseDate, to: Date()).day ?? 0

        // SANITY CHECK 1: Streak can't be longer than the account has existed
        // (You can't have a 100-day streak if your account is only 50 days old)
        guard currentStreak <= accountAgeDays else { return false }

        // SANITY CHECK 2: Streak can't exceed days since app release
        // (Prevents impossible streaks from before the app existed)
        guard currentStreak <= daysSinceRelease else { return false }

        // SANITY CHECK 3: Account must be at least 1 day old
        // (Prevents brand new accounts from appearing on leaderboard)
        guard accountAgeDays >= 1 else { return false }

        // SANITY CHECK 4: Reasonable maximum streak (10 years)
        // (Catches obviously fake data)
        guard currentStreak <= 3650 else { return false }

        return true
    }
}

// =============================================================================
// MARK: - LeaderboardType
// =============================================================================
/// The different ways users can be ranked on the leaderboard.
///
/// Each type sorts users by a different metric, allowing users to compete
/// in different categories based on their goals.

enum LeaderboardType: String, CaseIterable {
    /// Ranks users by their current consecutive day streak
    case streak = "Streak"

    /// Ranks users by points earned in the current week
    case weekly = "Weekly"

    /// Ranks users by points earned in the current month
    case monthly = "Monthly"

    /// Ranks users by total lifetime points
    case allTime = "All Time"

    /// The SF Symbol icon to display for this leaderboard type
    var icon: String {
        switch self {
        case .streak: return "flame.fill"      // Fire icon for streaks
        case .weekly: return "calendar"         // Calendar for weekly
        case .monthly: return "calendar.badge.clock"  // Calendar with clock for monthly
        case .allTime: return "trophy.fill"     // Trophy for all-time achievements
        }
    }

    /// The CloudKit field name to sort by when querying this leaderboard type
    var sortKey: String {
        switch self {
        case .streak: return "currentStreak"
        case .weekly: return "weeklyScore"
        case .monthly: return "monthlyScore"
        case .allTime: return "lifetimeScore"
        }
    }
}

// =============================================================================
// MARK: - LeaderboardScope
// =============================================================================
/// The different "views" or filters available for the leaderboard.
///
/// Users can toggle between these scopes to see different groups of people:
/// - Global: Everyone on the platform
/// - My Path: Only people with the same life goal (e.g., other Software Engineers)
/// - Friends: Only people they've added as friends

enum LeaderboardScope: String, CaseIterable {
    /// Shows all opted-in users across the entire platform
    case global = "Global"

    /// Shows only users who share the same life path as the current user
    /// For example, if you're a "Software Engineer", you only see other Software Engineers
    case path = "My Path"

    /// Shows only users the current user has added as friends
    case friends = "Friends"

    /// The SF Symbol icon to display for this scope
    var icon: String {
        switch self {
        case .global: return "globe"           // Globe for worldwide
        case .path: return "target"            // Target for focused competition
        case .friends: return "person.2.fill"  // Two people for friends
        }
    }
}

// =============================================================================
// MARK: - LeaderboardPathFilter
// =============================================================================
/// Used internally to filter leaderboard queries by life path.
///
/// This enum is used when fetching leaderboard data to optionally filter
/// results to only users on a specific life path.

enum LeaderboardPathFilter: Equatable {
    /// No filter - show all users regardless of their path
    case all

    /// Filter to only show users on a specific life path
    case path(LifePathCategory)

    /// Human-readable name for this filter
    var displayName: String {
        switch self {
        case .all:
            return "All Paths"
        case .path(let category):
            return category.displayName
        }
    }
}

// =============================================================================
// MARK: - LeaderboardService
// =============================================================================
/// The main service class that handles all leaderboard operations.
///
/// This is a singleton (@MainActor) that manages:
/// - Fetching leaderboard data from CloudKit
/// - Updating the current user's leaderboard entry
/// - Searching for users by friend code
/// - Managing opt-in/opt-out for global leaderboard
///
/// ## Usage
/// ```swift
/// // Fetch the global leaderboard sorted by streak
/// await LeaderboardService.shared.fetchLeaderboard(type: .streak, scope: .global)
///
/// // Access the results
/// let entries = LeaderboardService.shared.globalEntries
/// ```

@MainActor
final class LeaderboardService: ObservableObject {

    // MARK: - Singleton

    /// Shared instance - use this to access the leaderboard service throughout the app
    static let shared = LeaderboardService()

    // MARK: - Constants

    /// The date the app was released to the App Store.
    /// Used for sanity checks to prevent impossible streak claims.
    /// Timestamp: January 20, 2025 00:00:00 UTC
    static let appReleaseDate = Date(timeIntervalSince1970: 1737331200)

    // MARK: - CloudKit Properties

    /// The CloudKit container for this app (iCloud.com.lifeblock.app)
    private let container: CKContainer

    /// Reference to the public database where leaderboard data is stored
    /// We use the public database so all users can see each other's entries
    private let publicDB: CKDatabase

    // MARK: - Published Properties (Observable by UI)

    /// All entries for the global leaderboard (fetched from CloudKit)
    @Published var globalEntries: [LeaderboardEntry] = []

    /// Entries filtered by the user's current life path
    @Published var pathEntries: [LeaderboardEntry] = []

    /// Entries for the user's friends only
    @Published var friendEntries: [LeaderboardEntry] = []

    /// The current user's own leaderboard entry (if they're opted in)
    @Published var currentUserEntry: LeaderboardEntry?

    /// The current user's rank on the leaderboard (if applicable)
    @Published var currentUserRank: Int?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isOptedIntoGlobal: Bool = false
    @Published var selectedPathFilter: LeaderboardPathFilter = .all

    private init() {
        container = CKContainer(identifier: "iCloud.com.lifeblock.app")
        publicDB = container.publicCloudDatabase

        isOptedIntoGlobal = UserDefaults.standard.bool(forKey: "leaderboard.optedIntoGlobal")

        // Set path filter based on user's current path
        if let userPath = AppSettings.shared.userLifePath?.selectedPath {
            selectedPathFilter = .path(userPath)
        }
    }

    // MARK: - Public Methods

    /// Fetch leaderboard entries
    func fetchLeaderboard(type: LeaderboardType, scope: LeaderboardScope, pathFilter: LeaderboardPathFilter? = nil) async {
        isLoading = true
        error = nil

        do {
            switch scope {
            case .global:
                try await fetchGlobalLeaderboard(type: type, pathFilter: pathFilter)
            case .path:
                // Use user's current path
                if let userPath = AppSettings.shared.userLifePath?.selectedPath {
                    try await fetchGlobalLeaderboard(type: type, pathFilter: .path(userPath))
                } else {
                    try await fetchGlobalLeaderboard(type: type, pathFilter: nil)
                }
            case .friends:
                try await fetchFriendsLeaderboard(type: type)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    /// Search for a user by their friend code and return their info
    func searchUserByFriendCode(_ code: String) async -> Result<LeaderboardEntry, FriendError> {
        let normalizedCode = code.uppercased().trimmingCharacters(in: .whitespaces)

        // Check if it's own code
        if normalizedCode == AppSettings.shared.friendCode {
            return .failure(.cannotAddSelf)
        }

        // Search CloudKit for user with this friend code
        do {
            let predicate = NSPredicate(format: "friendCode == %@", normalizedCode)
            let query = CKQuery(recordType: "LeaderboardEntry", predicate: predicate)

            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)

            guard let (_, result) = results.first,
                  case .success(let record) = result,
                  let entry = LeaderboardEntry(from: record) else {
                return .failure(.userNotFound)
            }

            return .success(entry)
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }

    /// Generate a shareable invite link
    func generateInviteLink() -> URL? {
        let friendCode = AppSettings.shared.friendCode
        return URL(string: "lifeblocks://addfriend?code=\(friendCode)")
    }

    /// Get user's friend code (auto-generated by AppSettings)
    func getUserFriendCode() -> String {
        return AppSettings.shared.friendCode
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

    private func fetchGlobalLeaderboard(type: LeaderboardType, pathFilter: LeaderboardPathFilter?) async throws {
        var predicate: NSPredicate

        // Filter by path if specified
        if case .path(let category) = pathFilter {
            predicate = NSPredicate(format: "lifePath == %@", category.rawValue)
        } else {
            predicate = NSPredicate(value: true)
        }

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

        // Store in appropriate array
        if pathFilter != nil {
            pathEntries = entries
        } else {
            globalEntries = entries
        }
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
            lastUpdated: Date(),
            lifePath: settings.userLifePath?.selectedPath.rawValue,
            bio: settings.bio.isEmpty ? nil : settings.bio,
            friendCode: settings.friendCode
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
        record["lifePath"] = entry.lifePath
        record["bio"] = entry.bio
        record["friendCode"] = entry.friendCode ?? getUserFriendCode()

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
        self.lifePath = record["lifePath"] as? String
        self.bio = record["bio"] as? String
        self.friendCode = record["friendCode"] as? String
    }
}

// MARK: - Friend Errors

enum FriendError: LocalizedError {
    case userNotFound
    case alreadyFriends
    case cannotAddSelf
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "No user found with that friend code. Check the code and try again."
        case .alreadyFriends:
            return "You're already friends with this user!"
        case .cannotAddSelf:
            return "You can't add yourself as a friend."
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}
