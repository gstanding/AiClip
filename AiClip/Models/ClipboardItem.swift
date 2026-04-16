import Foundation
import SwiftData

@Model
final class ClipboardItem {
    var id: UUID
    var content: String
    var contentType: ContentType
    var category: ItemCategory
    var aiSummary: String?
    var aiTags: [String]
    var isPinned: Bool
    var isFavorite: Bool
    var sourceApp: String?
    var createdAt: Date
    var lastAccessedAt: Date
    var accessCount: Int

    init(
        content: String,
        contentType: ContentType = .text,
        category: ItemCategory = .uncategorized,
        aiSummary: String? = nil,
        aiTags: [String] = [],
        isPinned: Bool = false,
        isFavorite: Bool = false,
        sourceApp: String? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.contentType = contentType
        self.category = category
        self.aiSummary = aiSummary
        self.aiTags = aiTags
        self.isPinned = isPinned
        self.isFavorite = isFavorite
        self.sourceApp = sourceApp
        self.createdAt = Date()
        self.lastAccessedAt = Date()
        self.accessCount = 0
    }

    func markAccessed() {
        lastAccessedAt = Date()
        accessCount += 1
    }
}

enum ContentType: String, Codable, CaseIterable {
    case text = "text"
    case url = "url"
    case email = "email"
    case phone = "phone"
    case code = "code"
    case address = "address"
    case image = "image"
    case file = "file"
    case color = "color"
    case json = "json"

    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .url: return "link"
        case .email: return "envelope"
        case .phone: return "phone"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .address: return "mappin.and.ellipse"
        case .image: return "photo"
        case .file: return "doc"
        case .color: return "paintpalette"
        case .json: return "curlybraces"
        }
    }

    var displayName: String {
        switch self {
        case .text: return "Text"
        case .url: return "URL"
        case .email: return "Email"
        case .phone: return "Phone"
        case .code: return "Code"
        case .address: return "Address"
        case .image: return "Image"
        case .file: return "File"
        case .color: return "Color"
        case .json: return "JSON"
        }
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case uncategorized = "uncategorized"
    case work = "work"
    case personal = "personal"
    case development = "development"
    case research = "research"
    case communication = "communication"
    case finance = "finance"
    case social = "social"
    case shopping = "shopping"

    var icon: String {
        switch self {
        case .uncategorized: return "tray"
        case .work: return "briefcase"
        case .personal: return "person"
        case .development: return "hammer"
        case .research: return "magnifyingglass"
        case .communication: return "bubble.left.and.bubble.right"
        case .finance: return "dollarsign.circle"
        case .social: return "person.2"
        case .shopping: return "cart"
        }
    }

    var displayName: String {
        rawValue.capitalized
    }
}
