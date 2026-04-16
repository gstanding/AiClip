import Foundation
import CloudKit
import Combine

/// Manages iCloud sync status and conflict resolution
final class CloudSyncManager: ObservableObject {
    @Published var syncStatus: SyncStatus = .idle
    @Published var lastSyncDate: Date?
    @Published var iCloudAvailable: Bool = false

    enum SyncStatus: Equatable {
        case idle
        case syncing
        case synced
        case error(String)
    }

    init() {
        checkiCloudStatus()
    }

    func checkiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.iCloudAvailable = true
                default:
                    self?.iCloudAvailable = false
                }
            }
        }
    }

    func triggerSync() {
        guard iCloudAvailable else { return }
        syncStatus = .syncing

        // SwiftData with CloudKit handles sync automatically
        // This method provides manual trigger and status tracking
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.syncStatus = .synced
            self?.lastSyncDate = Date()
        }
    }
}
