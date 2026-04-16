import Foundation
import NaturalLanguage

/// On-device AI analysis service using Apple's NaturalLanguage framework
struct AIService {

    // MARK: - Content Type Detection

    static func detectContentType(_ text: String) -> ContentType {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        // URL detection
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(trimmed.startIndex..., in: trimmed)
            let matches = detector.matches(in: trimmed, range: range)
            if let match = matches.first, match.range.length == range.length {
                return .url
            }
        }

        // Email detection
        if isEmail(trimmed) {
            return .email
        }

        // Phone detection
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue) {
            let range = NSRange(trimmed.startIndex..., in: trimmed)
            let matches = detector.matches(in: trimmed, range: range)
            if let match = matches.first, match.range.length == range.length {
                return .phone
            }
        }

        // Address detection
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.address.rawValue) {
            let range = NSRange(trimmed.startIndex..., in: trimmed)
            let matches = detector.matches(in: trimmed, range: range)
            if !matches.isEmpty {
                let totalMatchLength = matches.reduce(0) { $0 + $1.range.length }
                if Double(totalMatchLength) / Double(range.length) > 0.5 {
                    return .address
                }
            }
        }

        // JSON detection
        if isJSON(trimmed) {
            return .json
        }

        // Code detection
        if isCode(trimmed) {
            return .code
        }

        // Color hex detection
        if isColorHex(trimmed) {
            return .color
        }

        return .text
    }

    // MARK: - Category Inference

    static func inferCategory(_ text: String, contentType: ContentType) -> ItemCategory {
        switch contentType {
        case .code, .json:
            return .development
        case .url:
            return categorizeURL(text)
        case .email:
            return .communication
        case .phone:
            return .communication
        default:
            return categorizeByContent(text)
        }
    }

    // MARK: - AI Summary

    static func generateSummary(_ text: String, contentType: ContentType) -> String {
        switch contentType {
        case .url:
            return "Link: \(extractDomain(text))"
        case .email:
            return "Email address"
        case .phone:
            return "Phone number"
        case .code:
            return summarizeCode(text)
        case .json:
            return summarizeJSON(text)
        case .color:
            return "Color: \(text)"
        case .address:
            return "Address"
        default:
            return summarizeText(text)
        }
    }

    // MARK: - Tag Generation

    static func generateTags(_ text: String, contentType: ContentType) -> [String] {
        var tags: [String] = []

        // Add content type tag
        tags.append(contentType.displayName.lowercased())

        // Language detection
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        if let language = recognizer.dominantLanguage {
            let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)
            if let name = languageName {
                tags.append(name.lowercased())
            }
        }

        // Named entity recognition
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text
        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace]
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: options) { tag, _ in
            if let tag = tag {
                switch tag {
                case .personalName:
                    tags.append("person")
                case .placeName:
                    tags.append("place")
                case .organizationName:
                    tags.append("organization")
                default:
                    break
                }
            }
            return true
        }

        // Content-specific tags
        switch contentType {
        case .url:
            let domain = extractDomain(text)
            tags.append(domain)
        case .code:
            tags.append(contentsOf: detectProgrammingLanguage(text))
        default:
            break
        }

        // Deduplicate
        return Array(Set(tags))
    }

    // MARK: - Smart Search

    static func semanticMatch(_ text: String, query: String) -> Double {
        let embedding = NLEmbedding.sentenceEmbedding(for: .english)
        if let distance = embedding?.distance(between: text.lowercased(), and: query.lowercased()) {
            return max(0, 1.0 - Double(distance))
        }

        // Fallback to basic matching
        let textLower = text.lowercased()
        let queryLower = query.lowercased()

        if textLower.contains(queryLower) {
            return 0.9
        }

        let queryWords = queryLower.split(separator: " ")
        let matchCount = queryWords.filter { textLower.contains($0) }.count
        return Double(matchCount) / Double(max(queryWords.count, 1))
    }

    // MARK: - Private Helpers

    private static func isEmail(_ text: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func isJSON(_ text: String) -> Bool {
        guard let data = text.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }

    private static func isCode(_ text: String) -> Bool {
        let codeIndicators = [
            "func ", "class ", "struct ", "enum ", "import ",
            "def ", "return ", "if (", "for (", "while (",
            "const ", "let ", "var ", "function ",
            "public ", "private ", "static ",
            "->", "=>", "!=", "==", "&&", "||",
            "{", "}", "();", "[];",
        ]
        let matchCount = codeIndicators.filter { text.contains($0) }.count
        return matchCount >= 3
    }

    private static func isColorHex(_ text: String) -> Bool {
        let pattern = #"^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3}|[A-Fa-f0-9]{8})$"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    private static func extractDomain(_ url: String) -> String {
        guard let url = URL(string: url), let host = url.host else {
            return "unknown"
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    private static func categorizeURL(_ url: String) -> ItemCategory {
        let domain = extractDomain(url).lowercased()

        let socialDomains = ["twitter.com", "x.com", "facebook.com", "instagram.com", "tiktok.com", "reddit.com", "linkedin.com", "mastodon.social"]
        let shoppingDomains = ["amazon.com", "ebay.com", "shopify.com", "etsy.com", "walmart.com", "taobao.com", "jd.com"]
        let devDomains = ["github.com", "gitlab.com", "stackoverflow.com", "developer.apple.com", "npmjs.com", "pypi.org"]
        let financeDomains = ["paypal.com", "stripe.com", "bank", "finance"]

        if socialDomains.contains(where: { domain.contains($0) }) { return .social }
        if shoppingDomains.contains(where: { domain.contains($0) }) { return .shopping }
        if devDomains.contains(where: { domain.contains($0) }) { return .development }
        if financeDomains.contains(where: { domain.contains($0) }) { return .finance }

        return .research
    }

    private static func categorizeByContent(_ text: String) -> ItemCategory {
        let lower = text.lowercased()

        let workKeywords = ["meeting", "deadline", "project", "task", "report", "presentation", "client", "schedule"]
        let financeKeywords = ["price", "cost", "payment", "invoice", "budget", "salary", "tax", "account"]
        let devKeywords = ["bug", "feature", "deploy", "commit", "merge", "pull request", "api", "database"]

        let workScore = workKeywords.filter { lower.contains($0) }.count
        let financeScore = financeKeywords.filter { lower.contains($0) }.count
        let devScore = devKeywords.filter { lower.contains($0) }.count

        let maxScore = max(workScore, financeScore, devScore)
        guard maxScore > 0 else { return .uncategorized }

        if maxScore == workScore { return .work }
        if maxScore == financeScore { return .finance }
        return .development
    }

    private static func summarizeText(_ text: String) -> String {
        let words = text.split(separator: " ")
        if words.count <= 10 {
            return String(text.prefix(100))
        }
        let preview = words.prefix(10).joined(separator: " ")
        return "\(preview)... (\(words.count) words)"
    }

    private static func summarizeCode(_ text: String) -> String {
        let lines = text.components(separatedBy: .newlines)
        let languages = detectProgrammingLanguage(text)
        let langStr = languages.first ?? "code"
        return "\(langStr.capitalized) snippet (\(lines.count) lines)"
    }

    private static func summarizeJSON(_ text: String) -> String {
        guard let data = text.data(using: .utf8) else { return "JSON data" }
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return "JSON object (\(dict.count) keys)"
        }
        if let arr = try? JSONSerialization.jsonObject(with: data) as? [Any] {
            return "JSON array (\(arr.count) items)"
        }
        return "JSON data"
    }

    private static func detectProgrammingLanguage(_ text: String) -> [String] {
        var languages: [String] = []

        if text.contains("import SwiftUI") || text.contains("import Foundation") || text.contains("func ") && text.contains("->") {
            languages.append("swift")
        }
        if text.contains("import ") && text.contains("def ") || text.contains("print(") && text.contains("self.") {
            languages.append("python")
        }
        if text.contains("function ") || text.contains("const ") || text.contains("=>") {
            languages.append("javascript")
        }
        if text.contains("<html") || text.contains("<div") || text.contains("</") {
            languages.append("html")
        }
        if text.contains("package ") && text.contains("func ") && text.contains(":=") {
            languages.append("go")
        }

        return languages.isEmpty ? ["code"] : languages
    }
}
