import SwiftUI

struct ClipboardItemRow: View {
    let item: ClipboardItem
    @EnvironmentObject var clipboardManager: ClipboardManager
    @State private var isHovered = false

    var body: some View {
        HStack(spacing: 12) {
            // Content type icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(contentTypeColor.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: item.contentType.icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(contentTypeColor)
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }

                    Text(item.aiSummary ?? item.content.prefix(60).description)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }

                Text(item.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack(alignment: .center, spacing: 0) {
                    // Tags (scrollable row, max 2 shown)
                    HStack(spacing: 4) {
                        ForEach(item.aiTags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .lineLimit(1)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .layoutPriority(0)

                    Spacer(minLength: 6)

                    // Timestamp — fixed width, never compressed
                    Text(item.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .layoutPriority(1)
                }
            }

            Spacer()

            // Quick actions
            if isHovered {
                HStack(spacing: 4) {
                    Button {
                        clipboardManager.copyToClipboard(item)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)

                    Button {
                        item.isPinned.toggle()
                    } label: {
                        Image(systemName: item.isPinned ? "pin.slash.fill" : "pin")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }

    private var contentTypeColor: Color {
        switch item.contentType {
        case .url: return .blue
        case .email: return .orange
        case .phone: return .green
        case .code: return .purple
        case .json: return .indigo
        case .color: return .pink
        case .address: return .teal
        case .image: return .cyan
        case .file: return .brown
        case .text: return .gray
        }
    }
}
