import XCTest

@MainActor
final class ModalSupportViewUITests: AIChatUITestCase {
    func testBackdropIsRemovedWhenModalClosesAndCanBePresentedAgain() {
        openRatingsModal()
        assertExists(element(AccessibilityID.Modal.backdrop))
        tap(AccessibilityID.Modal.secondary(AccessibilityID.Modal.rating))
        assertGone(element(AccessibilityID.Modal.backdrop))
        tap(AccessibilityID.Settings.rating)
        assertExists(element(AccessibilityID.Modal.backdrop))
        assertExists(element(AccessibilityID.Modal.title(AccessibilityID.Modal.rating)))
    }
}
