import Foundation
import Combine

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
        if let token = FileManager.default.ubiquityIdentityToken {
            iCloudAvailable = true
        } else {
            iCloudAvailable = false
        }
    }

    func triggerSync() {
        guard iCloudAvailable else { return }
        syncStatus = .syncing

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.syncStatus = .synced
            self?.lastSyncDate = Date()
        }
    }
}
