import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ClipboardEntry: TimelineEntry {
    let date: Date
    let recentClips: [WidgetClipItem]
}

struct WidgetClipItem: Identifiable {
    let id = UUID()
    let content: String
    let contentType: String
    let icon: String
    let timestamp: Date
}

struct ClipboardTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClipboardEntry {
        ClipboardEntry(
            date: Date(),
            recentClips: [
                WidgetClipItem(content: "Hello World", contentType: "Text", icon: "doc.text", timestamp: Date()),
                WidgetClipItem(content: "https://apple.com", contentType: "URL", icon: "link", timestamp: Date()),
                WidgetClipItem(content: "user@email.com", contentType: "Email", icon: "envelope", timestamp: Date()),
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ClipboardEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ClipboardEntry>) -> Void) {
        // Load recent clips from shared UserDefaults/App Group
        let clips = loadRecentClips()
        let entry = ClipboardEntry(date: Date(), recentClips: clips)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadRecentClips() -> [WidgetClipItem] {
        // Load from shared App Group UserDefaults
        guard let defaults = UserDefaults(suiteName: "group.com.aiclip.app"),
              let data = defaults.data(forKey: "recentClips"),
              let decoded = try? JSONDecoder().decode([WidgetClipData].self, from: data) else {
            return [
                WidgetClipItem(content: "Copy something to get started", contentType: "Text", icon: "doc.text", timestamp: Date()),
            ]
        }

        return decoded.map { clip in
            WidgetClipItem(
                content: clip.content,
                contentType: clip.contentType,
                icon: clip.icon,
                timestamp: clip.timestamp
            )
        }
    }
}

struct WidgetClipData: Codable {
    let content: String
    let contentType: String
    let icon: String
    let timestamp: Date
}

// MARK: - Widget Views

struct AiClipWidgetEntryView: View {
    var entry: ClipboardEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        case .systemLarge:
            largeWidget
        default:
            smallWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(.accent)
                Text("AiClip")
                    .font(.caption)
                    .fontWeight(.semibold)
            }

            if let firstClip = entry.recentClips.first {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: firstClip.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(firstClip.content)
                        .font(.caption2)
                        .lineLimit(3)
                        .foregroundStyle(.primary)

                    Text(firstClip.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding()
    }

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(.accent)
                Text("AiClip")
                    .font(.caption)
                    .fontWeight(.semibold)

                Spacer()

                Text("\(entry.recentClips.count) clips")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(entry.recentClips.prefix(3)) { clip in
                HStack(spacing: 8) {
                    Image(systemName: clip.icon)
                        .font(.caption2)
                        .foregroundStyle(.accent)
                        .frame(width: 16)

                    Text(clip.content)
                        .font(.caption2)
                        .lineLimit(1)

                    Spacer()

                    Text(clip.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding()
    }

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(.accent)
                Text("AiClip - Recent Clips")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()
            }

            Divider()

            ForEach(entry.recentClips.prefix(8)) { clip in
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.accentColor.opacity(0.15))
                            .frame(width: 24, height: 24)
                        Image(systemName: clip.icon)
                            .font(.caption2)
                            .foregroundStyle(.accent)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(clip.content)
                            .font(.caption)
                            .lineLimit(1)

                        Text(clip.contentType)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(clip.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct AiClipWidget: Widget {
    let kind: String = "AiClipWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClipboardTimelineProvider()) { entry in
            AiClipWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("AiClip")
        .description("View your recent clipboard history.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Widget Bundle

@main
struct AiClipWidgetBundle: WidgetBundle {
    var body: some Widget {
        AiClipWidget
    }
}

// MARK: - Preview

#Preview(as: .systemMedium) {
    AiClipWidget()
} timeline: {
    ClipboardEntry(
        date: Date(),
        recentClips: [
            WidgetClipItem(content: "https://developer.apple.com", contentType: "URL", icon: "link", timestamp: Date()),
            WidgetClipItem(content: "Hello World", contentType: "Text", icon: "doc.text", timestamp: Date().addingTimeInterval(-300)),
            WidgetClipItem(content: "user@example.com", contentType: "Email", icon: "envelope", timestamp: Date().addingTimeInterval(-600)),
        ]
    )
}
