import XCTest

@MainActor
final class RootViewUITests: AIChatUITestCase {
    func testWelcomeLaunchStateDoesNotShowTabs() {
        launch(at: .welcome)
        XCTAssertFalse(element(AccessibilityID.Explore.list).exists)
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testMainLaunchStateShowsExplore() {
        launch()
        assertExists(app.tabBars.buttons["Explore"])
        XCTAssertTrue(app.tabBars.buttons["Explore"].isSelected)
        XCTAssertFalse(element(AccessibilityID.Welcome.title).exists)
    }

    func testSuccessfulSignInReplacesWelcomeWithMainScreen() {
        openSignIn()
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        enter("UITestPassword123", into: AccessibilityID.Account.password)
        tap(AccessibilityID.Account.submit)
        assertExists(element(AccessibilityID.Explore.list))
        assertGone(element(AccessibilityID.Account.email))
        assertGone(element(AccessibilityID.Welcome.title))
    }
}
