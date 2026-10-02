import XCTest

@MainActor
final class RecentsCellViewUITests: AIChatUITestCase {
    func testRecentAvatarOpensTheMatchingConversation() {
        launch()
        selectTab("Chats")
        let recent = AccessibilityID.Chats.recent(UITestFixture.betaId)
        swipeTo(recent, in: AccessibilityID.Chats.recents)
        assertLabel(element(recent), contains: "Beta")
        tap(recent)
        assertExists(app.navigationBars["Beta"])
        assertExists(message(UITestFixture.betaGreeting))
    }
}
