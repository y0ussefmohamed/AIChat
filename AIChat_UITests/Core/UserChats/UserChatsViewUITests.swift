import XCTest

@MainActor
final class UserChatsViewUITests: AIChatUITestCase {
    func testChatsShowsRecentAvatarsAndResolvedConversationRows() {
        launch()
        selectTab("Chats")
        assertExists(element(AccessibilityID.Chats.recents))
        let alpha = element(AccessibilityID.Chats.row(UITestFixture.alphaChatId))
        assertLabel(alpha, contains: "Alpha")
        assertLabel(alpha, contains: UITestFixture.greeting)
        assertExists(element(AccessibilityID.Chats.recent(UITestFixture.betaId)))
    }

    func testEmptyChatsOffersExploreNavigation() {
        launch(.emptyChats)
        selectTab("Chats")
        assertExists(element(AccessibilityID.Chats.empty))
        tap(AccessibilityID.Chats.explore)
        assertExists(element(AccessibilityID.Explore.list))
        XCTAssertTrue(app.tabBars.buttons["Explore"].isSelected)
    }

    func testSelectingConversationOpensItsAvatarAndMessages() {
        launch()
        selectTab("Chats")
        tap(AccessibilityID.Chats.row(UITestFixture.betaChatId))
        assertExists(element(AccessibilityID.Chat.composer))
        assertExists(message(UITestFixture.betaGreeting))
        assertExists(app.navigationBars["Beta"])
    }
}
