import XCTest

@MainActor
final class CategoryListViewUITests: AIChatUITestCase {
    func testCategoryFiltersItsAvatarsAndOpensMatchingConversation() {
        openCategory()
        let alpha = AccessibilityID.Category.avatar(UITestFixture.alphaId)
        assertExists(element(alpha))
        assertLabel(element(AccessibilityID.Category.title), contains: "Aliens")
        XCTAssertFalse(element(AccessibilityID.Category.avatar(UITestFixture.betaId)).exists)
        tap(alpha)
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
    }

    func testEmptyCategoryShowsUnavailableState() {
        openCategory(.emptyCategory)
        assertExists(element(AccessibilityID.Category.empty))
        assertLabel(element(AccessibilityID.Category.empty), contains: "No Aliens Found")
        XCTAssertFalse(element(AccessibilityID.Category.avatar(UITestFixture.alphaId)).exists)
    }

    func testCategoryLoadFailureShowsAlertAndLeavesCategoryScreen() {
        openCategory(.categoryFailure)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Category.list))
        assertExists(element(AccessibilityID.Category.empty))
    }
}
