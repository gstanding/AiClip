import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var selectedTab: AppTab = .all
    @State private var searchText = ""
    @State private var selectedItem: ClipboardItem?

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
        } content: {
            ClipboardListView(
                selectedTab: selectedTab,
                searchText: $searchText,
                selectedItem: $selectedItem
            )
        } detail: {
            if let item = selectedItem {
                DetailView(item: item)
            } else {
                emptyDetailView
            }
        }
        .searchable(text: $searchText, prompt: "Search clips...")
        .navigationTitle("AiClip")
        .frame(minWidth: 700, minHeight: 400)
        .onAppear {
            clipboardManager.startMonitoring()
        }
        #else
        TabView(selection: $selectedTab) {
            NavigationStack {
                ClipboardListView(
                    selectedTab: .all,
                    searchText: $searchText,
                    selectedItem: $selectedItem
                )
                .searchable(text: $searchText, prompt: "Search clips...")
                .navigationTitle("All Clips")
            }
            .tabItem {
                Label("All", systemImage: "list.clipboard")
            }
            .tag(AppTab.all)

            NavigationStack {
                ClipboardListView(
                    selectedTab: .pinned,
                    searchText: $searchText,
                    selectedItem: $selectedItem
                )
                .searchable(text: $searchText, prompt: "Search pinned...")
                .navigationTitle("Pinned")
            }
            .tabItem {
                Label("Pinned", systemImage: "pin.fill")
            }
            .tag(AppTab.pinned)

            NavigationStack {
                CategoriesView()
                    .navigationTitle("Categories")
            }
            .tabItem {
                Label("Categories", systemImage: "folder.fill")
            }
            .tag(AppTab.categories)

            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppTab.settings)
        }
        .onAppear {
            clipboardManager.startMonitoring()
        }
        #endif
    }

    private var emptyDetailView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clipboard")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Select a clip to view details")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

enum AppTab: String, Hashable {
    case all
    case pinned
    case categories
    case settings
}
