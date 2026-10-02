import XCTest

@MainActor
final class HeroCellViewUITests: AIChatUITestCase {
    func testFeaturedHeroShowsAvatarDetailsAndOpensMatchingChat() {
        launch()
        let hero = AccessibilityID.Explore.featured(UITestFixture.alphaId)
        assertLabel(element(hero), contains: "Alpha")
        assertLabel(element(hero), contains: "An alien that is smiling in the park.")
        tap(hero)
        assertExists(element(AccessibilityID.Chat.message(UITestFixture.greetingId)))
    }
}
