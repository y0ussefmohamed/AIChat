import Foundation
import XCTest

@MainActor
final class CarouselViewUITests: AIChatUITestCase {
    func testPagingRevealsNextAvatarAndItsConversation() {
        launch()
        let first = element(AccessibilityID.Explore.featured(UITestFixture.alphaId))
        assertExists(first)
        XCTAssertTrue(first.isHittable)
        element(AccessibilityID.Explore.carousel).swipeLeft()
        let next = element(AccessibilityID.Explore.featured(UITestFixture.betaId))
        wait(next, for: NSPredicate(format: "hittable == true"))
        tap(AccessibilityID.Explore.featured(UITestFixture.betaId))
        assertExists(app.navigationBars["Beta"])
        assertExists(message(UITestFixture.betaGreeting))
    }
}
