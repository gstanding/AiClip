import XCTest

final class AiClipUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testAppLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Verify the app launched successfully
        XCTAssertTrue(app.exists)
    }

    func testSearchBarExists() throws {
        let app = XCUIApplication()
        app.launch()

        // The search field should be available
        let searchField = app.searchFields.firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5))
    }

    func testSettingsNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        #if os(iOS)
        // Navigate to settings tab
        let settingsTab = app.tabBars.buttons["Settings"]
        if settingsTab.exists {
            settingsTab.tap()
            XCTAssertTrue(app.navigationBars["Settings"].exists)
        }
        #endif
    }

    func testCategoriesNavigation() throws {
        let app = XCUIApplication()
        app.launch()

        #if os(iOS)
        let categoriesTab = app.tabBars.buttons["Categories"]
        if categoriesTab.exists {
            categoriesTab.tap()
            XCTAssertTrue(app.navigationBars["Categories"].exists)
        }
        #endif
    }
}
