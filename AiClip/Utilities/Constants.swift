import Foundation

enum AppConstants {
    static let appName = "AiClip"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"

    enum Defaults {
        static let maxHistoryCount = 500
        static let retentionDays = 30
        static let checkInterval: TimeInterval = 0.5
    }

    enum CloudKit {
        static let containerIdentifier = "iCloud.com.aiclip.app"
    }

    enum UserDefaultsKeys {
        static let maxHistoryCount = "maxHistoryCount"
        static let autoCategorizationEnabled = "autoCategorizationEnabled"
        static let ignoreDuplicates = "ignoreDuplicates"
        static let monitoringEnabled = "monitoringEnabled"
        static let showNotifications = "showNotifications"
        static let soundEnabled = "soundEnabled"
        static let retentionDays = "retentionDays"
    }
}
