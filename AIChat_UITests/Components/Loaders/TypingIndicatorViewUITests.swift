import XCTest

@MainActor
final class TypingIndicatorViewUITests: AIChatUITestCase {
    func testTypingIndicatorIsVisibleWhileReplyIsPendingAndThenDisappears() {
        openChat(.slowReply)
        send("Show the typing indicator")
        let typing = element(AccessibilityID.Chat.typing)
        assertExists(typing)
        XCTAssertEqual(typing.label, "Avatar is typing")
        assertExists(message(UITestFixture.reply))
        assertGone(typing)
    }
}
