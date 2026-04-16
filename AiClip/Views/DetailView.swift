import SwiftUI

struct DetailView: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var isEditing = false
    @State private var editedContent: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection

                Divider()

                // Content
                contentSection

                Divider()

                // AI Analysis
                aiAnalysisSection

                Divider()

                // Metadata
                metadataSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle("Clip Detail")
        #if os(macOS)
        .navigationSubtitle(item.contentType.displayName)
        #endif
        .toolbar {
            ToolbarItemGroup {
                Button {
                    clipboardManager.copyToClipboard(item)
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }

                Button {
                    item.isPinned.toggle()
                } label: {
                    Label(
                        item.isPinned ? "Unpin" : "Pin",
                        systemImage: item.isPinned ? "pin.slash.fill" : "pin"
                    )
                }

                Button {
                    item.isFavorite.toggle()
                } label: {
                    Label(
                        item.isFavorite ? "Unfavorite" : "Favorite",
                        systemImage: item.isFavorite ? "heart.fill" : "heart"
                    )
                }
            }
        }
    }

    private var headerSection: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: item.contentType.icon)
                    .font(.title2)
                    .foregroundStyle(.accent)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.aiSummary ?? "Clipboard Item")
                    .font(.headline)

                HStack(spacing: 8) {
                    Label(item.contentType.displayName, systemImage: item.contentType.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Label(item.category.displayName, systemImage: item.category.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if item.isPinned {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Label("Pinned", systemImage: "pin.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer()
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Content")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Button {
                    isEditing.toggle()
                    if isEditing {
                        editedContent = item.content
                    }
                } label: {
                    Text(isEditing ? "Done" : "Edit")
                        .font(.caption)
                }
            }

            if isEditing {
                TextEditor(text: $editedContent)
                    .font(.system(.body, design: item.contentType == .code ? .monospaced : .default))
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color.secondary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onChange(of: editedContent) { _, newValue in
                        item.content = newValue
                    }
            } else {
                Text(item.content)
                    .font(.system(.body, design: item.contentType == .code ? .monospaced : .default))
                    .textSelection(.enabled)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.secondary.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            if item.contentType == .url {
                Link(destination: URL(string: item.content) ?? URL(string: "about:blank")!) {
                    Label("Open Link", systemImage: "arrow.up.right.square")
                        .font(.caption)
                }
            }
        }
    }

    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Analysis")
                .font(.subheadline)
                .fontWeight(.semibold)

            if let summary = item.aiSummary {
                HStack(alignment: .top) {
                    Image(systemName: "brain")
                        .foregroundStyle(.purple)
                    Text(summary)
                        .font(.callout)
                }
            }

            if !item.aiTags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tags")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    FlowLayout(spacing: 6) {
                        ForEach(item.aiTags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundStyle(.accent)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            HStack {
                Label(item.category.displayName, systemImage: item.category.icon)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
        }
    }

    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Metadata")
                .font(.subheadline)
                .fontWeight(.semibold)

            Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    Text("Created")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.createdAt, style: .date)
                        .font(.caption)
                    + Text(" ")
                    + Text(item.createdAt, style: .time)
                        .font(.caption)
                }

                GridRow {
                    Text("Last Used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(item.lastAccessedAt, style: .relative)
                        .font(.caption)
                }

                GridRow {
                    Text("Times Used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(item.accessCount)")
                        .font(.caption)
                }

                if let sourceApp = item.sourceApp {
                    GridRow {
                        Text("Source App")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(sourceApp)
                            .font(.caption)
                    }
                }

                GridRow {
                    Text("Characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(item.content.count)")
                        .font(.caption)
                }
            }
        }
    }

    private var actionsSection: some View {
        HStack(spacing: 12) {
            Button {
                clipboardManager.copyToClipboard(item)
            } label: {
                Label("Copy to Clipboard", systemImage: "doc.on.doc")
            }
            .buttonStyle(.borderedProminent)

            Button(role: .destructive) {
                clipboardManager.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 8)
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX)
            totalHeight = max(totalHeight, currentY + lineHeight)
        }

        return (positions, CGSize(width: totalWidth, height: totalHeight))
    }
}
