#if os(macOS)
import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var searchText = ""
    @Environment(\.openWindow) private var openWindow

    var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return Array(clipboardManager.clipboardHistory.prefix(15))
        }
        return Array(clipboardManager.search(query: searchText).prefix(15))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(.accent)
                Text("AiClip")
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    clipboardManager.toggleMonitoring()
                } label: {
                    Circle()
                        .fill(clipboardManager.isMonitoring ? .green : .red)
                        .frame(width: 8, height: 8)
                }
                .buttonStyle(.plain)
                .help(clipboardManager.isMonitoring ? "Monitoring active" : "Monitoring paused")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search clips...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            Divider()

            // Clip list
            if filteredItems.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clipboard")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(searchText.isEmpty ? "No clips" : "No results")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredItems, id: \.id) { item in
                            MenuBarItemRow(item: item) {
                                clipboardManager.copyToClipboard(item)
                            }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 320)
            }

            Divider()

            // Footer actions
            HStack {
                Button("Open AiClip") {
                    openWindow(id: "main")
                }
                .buttonStyle(.plain)
                .font(.caption)

                Spacer()

                Button("Clear") {
                    clipboardManager.clearHistory()
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.red)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 320)
    }
}

struct MenuBarItemRow: View {
    let item: ClipboardItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: item.contentType.icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.content)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    if let summary = item.aiSummary {
                        Text(summary)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                Text(item.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif
