import Foundation
import SwiftData

// MARK: - Friend Model
/// Represents a connected friend for accountability features

@Model
final class Friend {
    var id: UUID
    var userID: String  // CloudKit record ID or unique identifier
    var displayName: String
    var avatarEmoji: String
    var connectionDate: Date
    var isAccountabilityPartner: Bool
    var lastActivityDate: Date?

    // Friend's shared stats (synced periodically)
    var currentStreak: Int
    var longestStreak: Int
    var weeklyScore: Int
    var totalCheckIns: Int

    // Connection status
    var status: ConnectionStatus

    enum ConnectionStatus: String, Codable {
        case pending = "pending"
        case connected = "connected"
        case blocked = "blocked"
    }

    init(
        userID: String,
        displayName: String,
        avatarEmoji: String = "👤",
        isAccountabilityPartner: Bool = false
    ) {
        self.id = UUID()
        self.userID = userID
        self.displayName = displayName
        self.avatarEmoji = avatarEmoji
        self.connectionDate = Date()
        self.isAccountabilityPartner = isAccountabilityPartner
        self.lastActivityDate = nil
        self.currentStreak = 0
        self.longestStreak = 0
        self.weeklyScore = 0
        self.totalCheckIns = 0
        self.status = .pending
    }
}

// MARK: - Friend Request Model

@Model
final class FriendRequest {
    var id: UUID
    var fromUserID: String
    var fromDisplayName: String
    var fromAvatarEmoji: String
    var toUserID: String
    var requestDate: Date
    var status: RequestStatus
    var includesAccountabilityPartner: Bool

    enum RequestStatus: String, Codable {
        case pending = "pending"
        case accepted = "accepted"
        case declined = "declined"
    }

    init(
        fromUserID: String,
        fromDisplayName: String,
        fromAvatarEmoji: String,
        toUserID: String,
        includesAccountabilityPartner: Bool = false
    ) {
        self.id = UUID()
        self.fromUserID = fromUserID
        self.fromDisplayName = fromDisplayName
        self.fromAvatarEmoji = fromAvatarEmoji
        self.toUserID = toUserID
        self.requestDate = Date()
        self.status = .pending
        self.includesAccountabilityPartner = includesAccountabilityPartner
    }
}

// MARK: - Cheer Model
/// Quick encouragement messages between friends

@Model
final class Cheer {
    var id: UUID
    var fromUserID: String
    var fromDisplayName: String
    var toUserID: String
    var message: CheerMessage
    var sentDate: Date
    var isRead: Bool

    enum CheerMessage: String, Codable, CaseIterable {
        case fire = "🔥"
        case clap = "👏"
        case star = "⭐️"
        case muscle = "💪"
        case rocket = "🚀"
        case heart = "❤️"
        case trophy = "🏆"
        case thumbsUp = "👍"

        var displayText: String {
            switch self {
            case .fire: return "You're on fire!"
            case .clap: return "Great job!"
            case .star: return "You're a star!"
            case .muscle: return "Keep pushing!"
            case .rocket: return "Crushing it!"
            case .heart: return "Proud of you!"
            case .trophy: return "Champion!"
            case .thumbsUp: return "Nice work!"
            }
        }
    }

    init(
        fromUserID: String,
        fromDisplayName: String,
        toUserID: String,
        message: CheerMessage
    ) {
        self.id = UUID()
        self.fromUserID = fromUserID
        self.fromDisplayName = fromDisplayName
        self.toUserID = toUserID
        self.message = message
        self.sentDate = Date()
        self.isRead = false
    }
}

// MARK: - User Profile for Sharing

struct UserProfile: Codable {
    let userID: String
    let displayName: String
    let avatarEmoji: String
    let currentStreak: Int
    let longestStreak: Int
    let weeklyScore: Int
    let totalCheckIns: Int
    let lastActiveDate: Date?

    static func fromAppSettings() -> UserProfile {
        let settings = AppSettings.shared
        return UserProfile(
            userID: settings.userID,
            displayName: settings.displayName,
            avatarEmoji: settings.avatarEmoji,
            currentStreak: settings.currentStreak,
            longestStreak: settings.longestStreak,
            weeklyScore: settings.weeklyScore,
            totalCheckIns: settings.totalCheckIns,
            lastActiveDate: settings.lastCheckInDate
        )
    }
}

// MARK: - App Settings Extension for Social Features

extension AppSettings {
    var userID: String {
        get {
            if let id = UserDefaults.standard.string(forKey: "userID") {
                return id
            }
            let newID = UUID().uuidString
            UserDefaults.standard.set(newID, forKey: "userID")
            return newID
        }
    }

    var displayName: String {
        get { UserDefaults.standard.string(forKey: "displayName") ?? "User" }
        set { UserDefaults.standard.set(newValue, forKey: "displayName") }
    }

    var avatarEmoji: String {
        get { UserDefaults.standard.string(forKey: "avatarEmoji") ?? "😀" }
        set { UserDefaults.standard.set(newValue, forKey: "avatarEmoji") }
    }

    var weeklyScore: Int {
        get { UserDefaults.standard.integer(forKey: "weeklyScore") }
        set { UserDefaults.standard.set(newValue, forKey: "weeklyScore") }
    }

    var totalCheckIns: Int {
        get { UserDefaults.standard.integer(forKey: "totalCheckIns") }
        set { UserDefaults.standard.set(newValue, forKey: "totalCheckIns") }
    }

    var friendCode: String {
        get {
            if let code = UserDefaults.standard.string(forKey: "friendCode") {
                return code
            }
            // Generate a short, shareable friend code
            let code = generateFriendCode()
            UserDefaults.standard.set(code, forKey: "friendCode")
            return code
        }
    }

    private func generateFriendCode() -> String {
        let letters = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
