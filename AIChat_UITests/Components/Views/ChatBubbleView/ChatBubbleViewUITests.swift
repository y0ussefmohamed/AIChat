import XCTest

@MainActor
final class ChatBubbleViewUITests: AIChatUITestCase {
    func testUserAndAvatarBubblesKeepTheirMessageContent() {
        openChat()
        let user = element(AccessibilityID.Chat.message(UITestFixture.previousUserMessageId))
        let avatar = element(AccessibilityID.Chat.message(UITestFixture.greetingId))
        assertExists(user)
        assertExists(avatar)
        XCTAssertEqual(user.label, UITestFixture.previousUserMessage)
        XCTAssertEqual(avatar.label, UITestFixture.greeting)
        XCTAssertGreaterThan(user.frame.minX, avatar.frame.minX)
    }

    func testNewMessagesAppearWithoutReopeningConversation() {
        openChat()
        send("This bubble arrived live")
        assertExists(message("This bubble arrived live"))
        assertExists(message(UITestFixture.reply))
        assertExists(element(AccessibilityID.Chat.composer))
    }
}
