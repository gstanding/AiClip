import SwiftUI

struct SidebarView: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject var clipboardManager: ClipboardManager

    var body: some View {
        List(selection: $selectedTab) {
            Section("Library") {
                Label("All Clips", systemImage: "list.clipboard")
                    .tag(AppTab.all)
                    .badge(clipboardManager.clipboardHistory.count)

                Label("Pinned", systemImage: "pin.fill")
                    .tag(AppTab.pinned)
                    .badge(clipboardManager.clipboardHistory.filter(\.isPinned).count)
            }

            Section("Categories") {
                ForEach(ItemCategory.allCases, id: \.self) { category in
                    let count = clipboardManager.items(for: category).count
                    if count > 0 {
                        Label(category.displayName, systemImage: category.icon)
                            .tag(AppTab.categories)
                            .badge(count)
                    }
                }
            }

            Section {
                Label("Settings", systemImage: "gear")
                    .tag(AppTab.settings)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("AiClip")
    }
}
