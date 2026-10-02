import XCTest

@MainActor
final class CategoryCellViewUITests: AIChatUITestCase {
    func testCategoryCardTitleCarriesIntoCategoryHeader() {
        launch()
        let cardId = AccessibilityID.Explore.category("alien")
        swipeTo(cardId, in: AccessibilityID.Explore.categories)
        assertLabel(element(cardId), contains: "Aliens")
        tap(cardId)
        assertLabel(element(AccessibilityID.Category.title), contains: "Aliens")
        assertExists(element(AccessibilityID.Category.avatar(UITestFixture.alphaId)))
    }
}
