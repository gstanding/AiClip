import SwiftUI
import SwiftData

struct ClipboardListView: View {
    let selectedTab: AppTab
    @Binding var searchText: String
    @Binding var selectedItem: ClipboardItem?
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var sortOrder: SortOrder = .newest

    enum SortOrder: String, CaseIterable {
        case newest = "Newest"
        case oldest = "Oldest"
        case mostUsed = "Most Used"
        case alphabetical = "A-Z"
    }

    var filteredItems: [ClipboardItem] {
        var items: [ClipboardItem]

        if searchText.isEmpty {
            items = clipboardManager.items(for: selectedTab)
        } else {
            items = clipboardManager.search(query: searchText)
        }

        switch sortOrder {
        case .newest:
            items.sort { $0.createdAt > $1.createdAt }
        case .oldest:
            items.sort { $0.createdAt < $1.createdAt }
        case .mostUsed:
            items.sort { $0.accessCount > $1.accessCount }
        case .alphabetical:
            items.sort { $0.content.lowercased() < $1.content.lowercased() }
        }

        return items
    }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("\(filteredItems.count) clips")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                Picker("Sort", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .pickerStyle(.menu)
                .fixedSize()

                Button {
                    clipboardManager.toggleMonitoring()
                } label: {
                    Image(systemName: clipboardManager.isMonitoring ? "pause.circle.fill" : "play.circle.fill")
                        .foregroundStyle(clipboardManager.isMonitoring ? .green : .secondary)
                }
                .buttonStyle(.plain)
                .help(clipboardManager.isMonitoring ? "Pause monitoring" : "Resume monitoring")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            if filteredItems.isEmpty {
                emptyStateView
            } else {
                List(filteredItems, id: \.id, selection: $selectedItem) { item in
                    ClipboardItemRow(item: item)
                        .contextMenu {
                            itemContextMenu(item)
                        }
                        .tag(item)
                }
                .listStyle(.plain)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty ? "clipboard" : "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            if searchText.isEmpty {
                Text("No clips yet")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Copy something to get started")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                Text("No results for \"\(searchText)\"")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                Text("Try a different search term")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func itemContextMenu(_ item: ClipboardItem) -> some View {
        Button {
            clipboardManager.copyToClipboard(item)
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }

        Button {
            item.isPinned.toggle()
        } label: {
            Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin")
        }

        Button {
            item.isFavorite.toggle()
        } label: {
            Label(item.isFavorite ? "Unfavorite" : "Favorite", systemImage: item.isFavorite ? "heart.slash" : "heart")
        }

        Divider()

        Menu("Category") {
            ForEach(ItemCategory.allCases, id: \.self) { category in
                Button {
                    item.category = category
                } label: {
                    if item.category == category {
                        Label(category.displayName, systemImage: "checkmark")
                    } else {
                        Text(category.displayName)
                    }
                }
            }
        }

        Divider()

        Button(role: .destructive) {
            clipboardManager.deleteItem(item)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}
