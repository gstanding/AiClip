import XCTest
@testable import AiClip

final class AiClipTests: XCTestCase {

    // MARK: - Content Type Detection Tests

    func testDetectURL() {
        let result = AIService.detectContentType("https://www.apple.com")
        XCTAssertEqual(result, .url)
    }

    func testDetectEmail() {
        let result = AIService.detectContentType("user@example.com")
        XCTAssertEqual(result, .email)
    }

    func testDetectPlainText() {
        let result = AIService.detectContentType("Hello, this is a plain text message.")
        XCTAssertEqual(result, .text)
    }

    func testDetectJSON() {
        let json = """
        {"name": "John", "age": 30, "city": "Tokyo"}
        """
        let result = AIService.detectContentType(json)
        XCTAssertEqual(result, .json)
    }

    func testDetectCode() {
        let code = """
        func calculateSum(a: Int, b: Int) -> Int {
            let result = a + b
            return result
        }
        """
        let result = AIService.detectContentType(code)
        XCTAssertEqual(result, .code)
    }

    func testDetectColorHex() {
        let result = AIService.detectContentType("#FF5733")
        XCTAssertEqual(result, .color)
    }

    // MARK: - Category Inference Tests

    func testCategorizeGitHubURL() {
        let result = AIService.inferCategory("https://github.com/apple/swift", contentType: .url)
        XCTAssertEqual(result, .development)
    }

    func testCategorizeTwitterURL() {
        let result = AIService.inferCategory("https://twitter.com/user/status/123", contentType: .url)
        XCTAssertEqual(result, .social)
    }

    func testCategorizeCode() {
        let result = AIService.inferCategory("let x = 42", contentType: .code)
        XCTAssertEqual(result, .development)
    }

    func testCategorizeEmail() {
        let result = AIService.inferCategory("user@example.com", contentType: .email)
        XCTAssertEqual(result, .communication)
    }

    // MARK: - Summary Generation Tests

    func testURLSummary() {
        let summary = AIService.generateSummary("https://www.apple.com/iphone", contentType: .url)
        XCTAssertTrue(summary.contains("apple.com"))
    }

    func testEmailSummary() {
        let summary = AIService.generateSummary("user@example.com", contentType: .email)
        XCTAssertEqual(summary, "Email address")
    }

    func testPhoneSummary() {
        let summary = AIService.generateSummary("+1-555-0123", contentType: .phone)
        XCTAssertEqual(summary, "Phone number")
    }

    func testTextSummary() {
        let longText = "This is a longer text that contains many words to test the summarization feature of the AI service component"
        let summary = AIService.generateSummary(longText, contentType: .text)
        XCTAssertTrue(summary.contains("words"))
    }

    // MARK: - Tag Generation Tests

    func testTagGeneration() {
        let tags = AIService.generateTags("Hello world", contentType: .text)
        XCTAssertFalse(tags.isEmpty)
        XCTAssertTrue(tags.contains("text"))
    }

    func testURLTagGeneration() {
        let tags = AIService.generateTags("https://github.com/project", contentType: .url)
        XCTAssertTrue(tags.contains("url"))
        XCTAssertTrue(tags.contains("github.com"))
    }

    // MARK: - ClipboardItem Model Tests

    func testClipboardItemCreation() {
        let item = ClipboardItem(
            content: "Test content",
            contentType: .text,
            category: .work
        )

        XCTAssertEqual(item.content, "Test content")
        XCTAssertEqual(item.contentType, .text)
        XCTAssertEqual(item.category, .work)
        XCTAssertFalse(item.isPinned)
        XCTAssertFalse(item.isFavorite)
        XCTAssertEqual(item.accessCount, 0)
    }

    func testClipboardItemAccess() {
        let item = ClipboardItem(content: "Test")
        XCTAssertEqual(item.accessCount, 0)

        item.markAccessed()
        XCTAssertEqual(item.accessCount, 1)

        item.markAccessed()
        XCTAssertEqual(item.accessCount, 2)
    }

    func testClipboardItemPin() {
        let item = ClipboardItem(content: "Test")
        XCTAssertFalse(item.isPinned)

        item.isPinned = true
        XCTAssertTrue(item.isPinned)
    }

    // MARK: - Content Type Tests

    func testContentTypeIcons() {
        for type in ContentType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an icon")
            XCTAssertFalse(type.displayName.isEmpty, "\(type) should have a display name")
        }
    }

    // MARK: - Category Tests

    func testCategoryProperties() {
        for category in ItemCategory.allCases {
            XCTAssertFalse(category.icon.isEmpty, "\(category) should have an icon")
            XCTAssertFalse(category.displayName.isEmpty, "\(category) should have a display name")
        }
    }

    // MARK: - Semantic Match Tests

    func testExactMatch() {
        let score = AIService.semanticMatch("hello world", query: "hello world")
        XCTAssertGreaterThan(score, 0.5)
    }

    func testPartialMatch() {
        let score = AIService.semanticMatch("hello world from Swift", query: "hello")
        XCTAssertGreaterThan(score, 0.3)
    }

    func testNoMatch() {
        let score = AIService.semanticMatch("hello world", query: "xyzabc123")
        XCTAssertLessThan(score, 0.5)
    }

    // MARK: - String Extension Tests

    func testTruncated() {
        let short = "Hello"
        XCTAssertEqual(short.truncated, "Hello")

        let long = String(repeating: "a", count: 200)
        XCTAssertTrue(long.truncated.count <= 103) // 100 + "..."
    }

    func testWordCount() {
        XCTAssertEqual("Hello world".wordCount, 2)
        XCTAssertEqual("One".wordCount, 1)
        XCTAssertEqual("This is a test sentence".wordCount, 5)
    }

    func testIsURL() {
        XCTAssertTrue("https://www.apple.com".isURL)
        XCTAssertFalse("just some text".isURL)
    }
}
