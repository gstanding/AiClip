import SwiftUI
import SwiftData

@main
struct AiClipApp: App {
    @StateObject private var clipboardManager = ClipboardManager()
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ClipboardItem.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("AiClip", systemImage: "clipboard.fill") {
            MenuBarView()
                .environmentObject(clipboardManager)
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)

        Window("AiClip", id: "main") {
            ContentView()
                .environmentObject(clipboardManager)
                .modelContainer(sharedModelContainer)
        }
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }

        Settings {
            SettingsView()
                .environmentObject(clipboardManager)
                .modelContainer(sharedModelContainer)
        }
        #else
        WindowGroup {
            ContentView()
                .environmentObject(clipboardManager)
                .modelContainer(sharedModelContainer)
        }
        #endif
    }
}
