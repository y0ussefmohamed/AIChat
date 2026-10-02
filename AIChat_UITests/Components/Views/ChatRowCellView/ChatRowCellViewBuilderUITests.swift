import XCTest

@MainActor
final class ChatRowCellViewBuilderUITests: AIChatUITestCase {
    func testOpeningConversationUpdatesItsReadStatusInList() {
        launch()
        selectTab("Chats")
        let id = AccessibilityID.Chats.row(UITestFixture.alphaChatId)
        assertLabel(element(id), contains: "Unread")
        tap(id)
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
        // The system navigation back button returns to this tab's existing list.
        app.navigationBars["Alpha"].buttons.firstMatch.tap()
        assertExists(element(AccessibilityID.Chats.list))
        assertLabel(element(id), contains: "Read")
    }
}
