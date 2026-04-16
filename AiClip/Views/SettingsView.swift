import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @StateObject private var syncManager = CloudSyncManager()

    @AppStorage("maxHistoryCount") private var maxHistoryCount: Int = 500
    @AppStorage("autoCategorizationEnabled") private var autoCategorizationEnabled: Bool = true
    @AppStorage("ignoreDuplicates") private var ignoreDuplicates: Bool = true
    @AppStorage("monitoringEnabled") private var monitoringEnabled: Bool = true
    @AppStorage("showNotifications") private var showNotifications: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = false
    @AppStorage("retentionDays") private var retentionDays: Int = 30

    var body: some View {
        Form {
            // General
            Section {
                Toggle("Enable Clipboard Monitoring", isOn: $monitoringEnabled)
                    .onChange(of: monitoringEnabled) { _, newValue in
                        if newValue {
                            clipboardManager.startMonitoring()
                        } else {
                            clipboardManager.stopMonitoring()
                        }
                    }

                Toggle("Ignore Duplicate Entries", isOn: $ignoreDuplicates)
                Toggle("Show Notifications", isOn: $showNotifications)
                Toggle("Sound Effects", isOn: $soundEnabled)
            } header: {
                Text("General")
            }

            // AI Features
            Section {
                Toggle("Auto Categorization", isOn: $autoCategorizationEnabled)

                VStack(alignment: .leading) {
                    Text("AI uses Apple NaturalLanguage framework for:")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 4) {
                        Label("Content type detection", systemImage: "doc.viewfinder")
                        Label("Auto categorization", systemImage: "folder.badge.gearshape")
                        Label("Smart tagging", systemImage: "tag")
                        Label("Semantic search", systemImage: "brain")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
                }
            } header: {
                Text("AI Features")
            }

            // Storage
            Section {
                Picker("Max History", selection: $maxHistoryCount) {
                    Text("100 items").tag(100)
                    Text("250 items").tag(250)
                    Text("500 items").tag(500)
                    Text("1000 items").tag(1000)
                    Text("Unlimited").tag(Int.max)
                }

                Picker("Auto Delete After", selection: $retentionDays) {
                    Text("7 days").tag(7)
                    Text("14 days").tag(14)
                    Text("30 days").tag(30)
                    Text("90 days").tag(90)
                    Text("Never").tag(0)
                }

                Button(role: .destructive) {
                    clipboardManager.clearHistory()
                } label: {
                    Label("Clear All History", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Storage")
            }

            // iCloud Sync
            Section {
                HStack {
                    Label("iCloud Status", systemImage: "icloud")
                    Spacer()
                    if syncManager.iCloudAvailable {
                        Text("Connected")
                            .foregroundStyle(.green)
                    } else {
                        Text("Not Available")
                            .foregroundStyle(.secondary)
                    }
                }

                if let lastSync = syncManager.lastSyncDate {
                    HStack {
                        Text("Last Sync")
                        Spacer()
                        Text(lastSync, style: .relative)
                            .foregroundStyle(.secondary)
                    }
                }

                Button {
                    syncManager.triggerSync()
                } label: {
                    Label("Sync Now", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(!syncManager.iCloudAvailable)
            } header: {
                Text("iCloud Sync")
            }

            // About
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("1")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("About")
            }

            #if os(macOS)
            Section {
                KeyboardShortcutSettingsView()
            } header: {
                Text("Keyboard Shortcuts")
            }
            #endif
        }
        .formStyle(.grouped)
    }
}

#if os(macOS)
struct KeyboardShortcutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            shortcutRow("Open AiClip", shortcut: "Cmd + Shift + V")
            shortcutRow("Quick Paste", shortcut: "Cmd + Shift + C")
            shortcutRow("Search Clips", shortcut: "Cmd + Shift + F")
            shortcutRow("Clear History", shortcut: "Cmd + Shift + Delete")
        }
    }

    private func shortcutRow(_ label: String, shortcut: String) -> some View {
        HStack {
            Text(label)
                .font(.callout)
            Spacer()
            Text(shortcut)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
#endif
