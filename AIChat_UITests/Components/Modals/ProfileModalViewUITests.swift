import XCTest

@MainActor
final class ProfileModalViewUITests: AIChatUITestCase {
    func testMessageAvatarOpensProfileWithMatchingNameAndDescription() {
        openProfileModal()
        XCTAssertEqual(element(AccessibilityID.Modal.profileTitle).label, "Alpha")
        XCTAssertEqual(element(AccessibilityID.Modal.profileSubtitle).label, "An alien that is smiling in the park.")
        tap(AccessibilityID.Modal.profileClose)
        assertGone(element(AccessibilityID.Modal.profileTitle))
        assertExists(element(AccessibilityID.Chat.composer))
    }

    func testEmptyConversationAvatarOpensSameProfile() {
        openProfileModal(.emptyConversation)
        XCTAssertEqual(element(AccessibilityID.Modal.profileTitle).label, "Alpha")
        tap(AccessibilityID.Modal.profileClose)
        assertGone(element(AccessibilityID.Modal.profileClose))
        assertExists(element(AccessibilityID.Chat.starter))
    }
}
