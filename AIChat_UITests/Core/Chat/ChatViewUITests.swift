import XCTest

@MainActor
final class ChatViewUITests: AIChatUITestCase {
    func testConversationLoadsMessagesAndDisablesEmptySend() {
        openChat()
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.previousUserMessageId)))
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
        XCTAssertFalse(element(AccessibilityID.Chat.send).isEnabled)
        XCTAssertFalse(element(AccessibilityID.Chat.starter).exists)
    }

    func testSendingShowsUserMessageAndStreamsAvatarReply() {
        openChat()
        send("Hello from a UI test")
        assertExists(message("Hello from a UI test"))
        assertExists(message(UITestFixture.reply))
        assertEmptyField(AccessibilityID.Chat.composer, placeholder: "Say something...")
        XCTAssertFalse(element(AccessibilityID.Chat.send).isEnabled)
    }

    func testStarterCreatesConversationAndStreamsMessages() {
        openChat(.emptyConversation)
        assertExists(element(AccessibilityID.Chat.starter))
        tap(AccessibilityID.Chat.starter)
        assertExists(message("Hello Alpha!"))
        assertExists(message(UITestFixture.reply))
        assertGone(element(AccessibilityID.Chat.starter))
    }

    func testFailedSendShowsErrorAndKeepsConversation() {
        openChat(.sendFailure)
        send("This message will fail")
        assertFixtureError()
        dismissAlert("Error")
        XCTAssertFalse(message("This message will fail").exists)
        assertExists(element(AccessibilityID.Chat.composer))
        assertEmptyField(AccessibilityID.Chat.composer, placeholder: "Say something...")
    }

    func testReportShowsConfirmationAndDismisses() {
        openChat()
        chatAction("Report User/Chat")
        dismissAlert("Report Submitted")
        assertExists(element(AccessibilityID.Chat.composer))
    }

    func testReportFailureShowsError() {
        openChat(.reportFailure)
        chatAction("Report User/Chat")
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Chat.composer))
    }

    func testDeleteConversationReturnsToProfile() {
        openChat()
        chatAction("Delete Chat")
        assertGone(element(AccessibilityID.Chat.composer))
        assertExists(element(AccessibilityID.Profile.list))
    }

    func testDeleteFailureKeepsConversationOpen() {
        openChat(.deleteChatFailure)
        chatAction("Delete Chat")
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
    }

    func testMessageStreamFailureLeavesEmptyConversationUsable() {
        openChat(.messageStreamFailure)
        // The existing view logs stream errors and leaves the conversation's empty state visible.
        assertExists(element(AccessibilityID.Chat.starter))
        assertExists(element(AccessibilityID.Chat.composer))
        XCTAssertFalse(element(AccessibilityID.Chat.message(UITestFixture.greetingId)).exists)
        XCTAssertFalse(element(AccessibilityID.Chat.send).isEnabled)
        enter("A new message", into: AccessibilityID.Chat.composer)
        XCTAssertTrue(element(AccessibilityID.Chat.send).isEnabled)
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    func testReplyFailurePreservesSentMessage() {
        openChat(.replyFailure)
        send("Keep this message")
        assertFixtureError()
        dismissAlert("Error")
        assertExists(message("Keep this message"))
        XCTAssertFalse(message(UITestFixture.reply).exists)
    }

    func testConversationActionsCanBeCancelled() {
        openChat()
        tap(AccessibilityID.Chat.actions)
        assertExists(app.buttons["Report User/Chat"])
        let cancel = app.buttons["Cancel"]
        if cancel.exists {
            cancel.tap()
        } else {
            // A native popover dismisses through its outside region instead of a Cancel action.
            let dismissRegion = element("PopoverDismissRegion")
            assertExists(dismissRegion)
            dismissRegion.tap()
        }
        assertGone(app.buttons["Report User/Chat"])
        assertExists(element(AccessibilityID.Chat.composer))
    }
}
