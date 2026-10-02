import XCTest

@MainActor
final class CustomModalViewUITests: AIChatUITestCase {
    func testRatingModalShowsBothActionsAndDismissesWithoutSystemReview() {
        openRatingsModal()
        let title = AccessibilityID.Modal.title(AccessibilityID.Modal.rating)
        XCTAssertEqual(element(title).label, "Are you enjoying AIChat?")
        assertExists(element(AccessibilityID.Modal.primary(AccessibilityID.Modal.rating)))
        tap(AccessibilityID.Modal.secondary(AccessibilityID.Modal.rating))
        assertGone(element(title))
        assertExists(element(AccessibilityID.Settings.list))
    }

    func testNotificationModalHasItsOwnIdentifierAndBothActions() {
        launch()
        tap(AccessibilityID.Explore.notifications)
        XCTAssertEqual(element(AccessibilityID.Modal.title(AccessibilityID.Modal.notifications)).label, "Enable Notifications")
        assertExists(element(AccessibilityID.Modal.primary(AccessibilityID.Modal.notifications)))
        assertExists(element(AccessibilityID.Modal.secondary(AccessibilityID.Modal.notifications)))
    }
}
