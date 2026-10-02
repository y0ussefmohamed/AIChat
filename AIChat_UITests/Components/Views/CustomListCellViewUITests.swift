import XCTest

@MainActor
final class CustomListCellViewUITests: AIChatUITestCase {
    func testCategoryRowDisplaysNameAndDescriptionAndOpensAvatar() {
        openCategory()
        let row = AccessibilityID.Category.avatar(UITestFixture.alphaId)
        assertLabel(element(row), contains: "Alpha")
        assertLabel(element(row), contains: "An alien that is smiling in the park.")
        tap(row)
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
    }

    func testProfileRowShowsOwnedAvatarAndOpensMatchingChat() {
        openProfile()
        tap(AccessibilityID.Profile.avatar(UITestFixture.betaId))
        assertExists(app.navigationBars["Beta"])
        assertExists(message(UITestFixture.betaGreeting))
    }
}
