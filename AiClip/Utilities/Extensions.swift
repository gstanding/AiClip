import Foundation
import SwiftUI

// MARK: - String Extensions

extension String {
    var isURL: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let range = NSRange(startIndex..., in: self)
        let matches = detector.matches(in: self, range: range)
        return matches.first?.range.length == range.length
    }

    var truncated: String {
        if count <= 100 {
            return self
        }
        return String(prefix(100)) + "..."
    }

    var wordCount: Int {
        split(separator: " ").count
    }

    var lineCount: Int {
        components(separatedBy: .newlines).count
    }
}

// MARK: - Date Extensions

extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var relativeDescription: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

// MARK: - View Extensions

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let clipboardDidChange = Notification.Name("clipboardDidChange")
    static let shouldCopyItem = Notification.Name("shouldCopyItem")
}
