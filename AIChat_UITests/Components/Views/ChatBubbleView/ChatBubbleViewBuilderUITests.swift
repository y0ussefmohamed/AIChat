import XCTest

@MainActor
final class ChatBubbleViewBuilderUITests: AIChatUITestCase {
    func testLongMessageRemainsCompleteAndWrapsInBubble() {
        openChat()
        let text = "This longer user message includes punctuation, numbers 12345, and enough words to wrap across multiple lines while keeping the complete conversation content."
        send(text)
        let bubble = message(text)
        assertExists(bubble)
        XCTAssertEqual(bubble.label, text)
        XCTAssertGreaterThan(bubble.frame.height, element(AccessibilityID.Chat.message(UITestFixture.previousUserMessageId)).frame.height)
    }

    func testConversationGroupsNearbyMessagesUnderOneTimestamp() {
        openChat()
        assertExists(element(AccessibilityID.Chat.timestamp(UITestFixture.previousUserMessageId)))
        XCTAssertFalse(element(AccessibilityID.Chat.timestamp(UITestFixture.greetingId)).exists)
    }
}
