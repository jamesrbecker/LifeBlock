import Foundation
import CloudKit
import SwiftUI

// MARK: - Cloud Sync Manager
/// Handles iCloud sync status and settings

@MainActor
final class CloudSyncManager: ObservableObject {
    static let shared = CloudSyncManager()

    @Published var syncStatus: SyncStatus = .unknown
    @Published var lastSyncDate: Date?
    @Published var iCloudAvailable: Bool = false

    enum SyncStatus: Equatable {
        case unknown
        case syncing
        case synced
        case error(String)
        case disabled

        var displayText: String {
            switch self {
            case .unknown: return "Checking..."
            case .syncing: return "Syncing..."
            case .synced: return "Up to date"
            case .error(let message): return "Error: \(message)"
            case .disabled: return "iCloud disabled"
            }
        }

        var icon: String {
            switch self {
            case .unknown: return "icloud.slash"
            case .syncing: return "arrow.triangle.2.circlepath.icloud"
            case .synced: return "checkmark.icloud"
            case .error: return "exclamationmark.icloud"
            case .disabled: return "icloud.slash"
            }
        }

        var color: Color {
            switch self {
            case .unknown: return .gray
            case .syncing: return .blue
            case .synced: return .green
            case .error: return .red
            case .disabled: return .gray
            }
        }
    }

    private init() {
        checkiCloudStatus()
    }

    func checkiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.iCloudAvailable = true
                    self?.syncStatus = .synced
                case .noAccount:
                    self?.iCloudAvailable = false
                    self?.syncStatus = .error("No iCloud account")
                case .restricted:
                    self?.iCloudAvailable = false
                    self?.syncStatus = .error("iCloud restricted")
                case .couldNotDetermine:
                    self?.iCloudAvailable = false
                    self?.syncStatus = .unknown
                case .temporarilyUnavailable:
                    self?.iCloudAvailable = false
                    self?.syncStatus = .error("Temporarily unavailable")
                @unknown default:
                    self?.iCloudAvailable = false
                    self?.syncStatus = .unknown
                }
            }
        }
    }

    func triggerSync() {
        syncStatus = .syncing
        // SwiftData with CloudKit syncs automatically
        // This is just for UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.syncStatus = .synced
            self?.lastSyncDate = Date()
        }
    }
}

// MARK: - Cloud Sync Settings View

struct CloudSyncSettingsView: View {
    @StateObject private var syncManager = CloudSyncManager.shared
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = true

    var body: some View {
        List {
            Section {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label {
                        VStack(alignment: .leading) {
                            Text("iCloud Sync")
                            Text("Sync data across your devices")
                                .font(.caption)
                                .foregroundStyle(Color.secondaryText)
                        }
                    } icon: {
                        Image(systemName: "icloud")
                            .foregroundStyle(.blue)
                    }
                }
            }

            Section("Sync Status") {
                HStack {
                    Image(systemName: syncManager.syncStatus.icon)
                        .foregroundStyle(syncManager.syncStatus.color)

                    Text(syncManager.syncStatus.displayText)

                    Spacer()

                    if syncManager.syncStatus == .syncing {
                        ProgressView()
                    }
                }

                if let lastSync = syncManager.lastSyncDate {
                    HStack {
                        Text("Last synced")
                            .foregroundStyle(Color.secondaryText)
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                Button(action: {
                    syncManager.triggerSync()
                }) {
                    Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(syncManager.syncStatus == .syncing || !syncManager.iCloudAvailable)
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label("How iCloud Sync Works", systemImage: "info.circle")
                        .font(.headline)

                    Text("When enabled, your habits, check-ins, and progress are automatically synced to iCloud and available on all your devices signed into the same Apple ID.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }
                .padding(.vertical, 8)
            }

            if !syncManager.iCloudAvailable {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("iCloud Not Available", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.orange)

                        Text("Make sure you're signed into iCloud in Settings and have iCloud Drive enabled.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)

                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Cloud Sync")
        .onAppear {
            syncManager.checkiCloudStatus()
        }
    }
}

// MARK: - Sync Status Badge

struct SyncStatusBadge: View {
    @StateObject private var syncManager = CloudSyncManager.shared

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: syncManager.syncStatus.icon)
                .font(.caption2)
            if syncManager.syncStatus == .syncing {
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
        .foregroundStyle(syncManager.syncStatus.color)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        CloudSyncSettingsView()
    }
    .preferredColorScheme(.dark)
}
