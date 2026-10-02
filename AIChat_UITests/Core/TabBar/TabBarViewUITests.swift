import XCTest

@MainActor
final class TabBarViewUITests: AIChatUITestCase {
    func testTabsDisplayTheirCorrespondingScreens() {
        launch()
        selectTab("Chats")
        assertExists(element(AccessibilityID.Chats.list))
        selectTab("Profile")
        assertExists(element(AccessibilityID.Profile.list))
        selectTab("Explore")
        assertExists(element(AccessibilityID.Explore.list))
    }

    func testSwitchingTabsPreservesProfileConversationNavigation() {
        openChat()
        selectTab("Explore")
        assertExists(element(AccessibilityID.Explore.list))
        selectTab("Profile")
        assertExists(element(AccessibilityID.Chat.composer))
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
    }
}
