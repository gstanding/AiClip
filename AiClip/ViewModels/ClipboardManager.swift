import Foundation
import SwiftUI
import SwiftData
import Combine

@MainActor
final class ClipboardManager: ObservableObject {
    @Published var isMonitoring = false
    @Published var clipboardHistory: [ClipboardItem] = []
    @Published var searchResults: [ClipboardItem] = []

    private let pasteboardMonitor = PasteboardMonitor()
    private var cancellables = Set<AnyCancellable>()

    // Settings
    @AppStorage("maxHistoryCount") var maxHistoryCount: Int = 500
    @AppStorage("autoCategorizationEnabled") var autoCategorizationEnabled: Bool = true
    @AppStorage("ignoreDuplicates") var ignoreDuplicates: Bool = true
    @AppStorage("monitoringEnabled") var monitoringEnabled: Bool = true

    init() {
        setupBindings()
    }

    private func setupBindings() {
        pasteboardMonitor.$latestContent
            .compactMap { $0 }
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.handleNewClipboardContent(content)
            }
            .store(in: &cancellables)
    }

    func startMonitoring() {
        guard monitoringEnabled else { return }
        pasteboardMonitor.startMonitoring()
        isMonitoring = true
    }

    func stopMonitoring() {
        pasteboardMonitor.stopMonitoring()
        isMonitoring = false
    }

    func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    private func handleNewClipboardContent(_ content: String) {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Check duplicates
        if ignoreDuplicates, clipboardHistory.first?.content == trimmed {
            return
        }

        // AI analysis
        let contentType = AIService.detectContentType(trimmed)
        let category = autoCategorizationEnabled ? AIService.inferCategory(trimmed, contentType: contentType) : .uncategorized
        let summary = AIService.generateSummary(trimmed, contentType: contentType)
        let tags = AIService.generateTags(trimmed, contentType: contentType)

        let item = ClipboardItem(
            content: trimmed,
            contentType: contentType,
            category: category,
            aiSummary: summary,
            aiTags: tags,
            sourceApp: getActiveAppName()
        )

        clipboardHistory.insert(item, at: 0)

        // Trim history
        if clipboardHistory.count > maxHistoryCount {
            clipboardHistory = Array(clipboardHistory.prefix(maxHistoryCount))
        }
    }

    func copyToClipboard(_ item: ClipboardItem) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(item.content, forType: .string)
        #else
        UIPasteboard.general.string = item.content
        #endif
        item.markAccessed()
    }

    func deleteItem(_ item: ClipboardItem) {
        clipboardHistory.removeAll { $0.id == item.id }
    }

    func clearHistory() {
        let pinned = clipboardHistory.filter { $0.isPinned }
        clipboardHistory = pinned
    }

    func search(query: String) -> [ClipboardItem] {
        guard !query.isEmpty else { return clipboardHistory }

        let queryLower = query.lowercased()

        return clipboardHistory
            .map { item -> (ClipboardItem, Double) in
                var score = 0.0

                // Direct content match
                if item.content.lowercased().contains(queryLower) {
                    score += 1.0
                }

                // Tag match
                if item.aiTags.contains(where: { $0.lowercased().contains(queryLower) }) {
                    score += 0.8
                }

                // Summary match
                if let summary = item.aiSummary?.lowercased(), summary.contains(queryLower) {
                    score += 0.6
                }

                // Category match
                if item.category.displayName.lowercased().contains(queryLower) {
                    score += 0.5
                }

                // Semantic match
                let semanticScore = AIService.semanticMatch(item.content, query: query)
                score += semanticScore * 0.4

                return (item, score)
            }
            .filter { $0.1 > 0.1 }
            .sorted { $0.1 > $1.1 }
            .map { $0.0 }
    }

    func items(for tab: AppTab) -> [ClipboardItem] {
        switch tab {
        case .all:
            return clipboardHistory
        case .pinned:
            return clipboardHistory.filter { $0.isPinned }
        case .categories, .settings:
            return clipboardHistory
        }
    }

    func items(for category: ItemCategory) -> [ClipboardItem] {
        clipboardHistory.filter { $0.category == category }
    }

    private func getActiveAppName() -> String? {
        #if os(macOS)
        return NSWorkspace.shared.frontmostApplication?.localizedName
        #else
        return nil
        #endif
    }
}

#if os(macOS)
import AppKit
#else
import UIKit
#endif
