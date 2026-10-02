import XCTest

@MainActor
final class AnyAppAlertUITests: AIChatUITestCase {
    func testErrorAlertHasLocalizedDescriptionAndDefaultDismissAction() {
        openSignIn(.authFailure)
        tap(AccessibilityID.Account.submit)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Account.email))
    }

    func testDestructiveAlertOffersCancellationAndConfirmation() {
        openSettings()
        tap(AccessibilityID.Settings.deleteAccount)
        let alert = app.alerts["Delete Account?"]
        assertExists(alert)
        assertExists(alert.buttons["Delete"])
        assertExists(alert.buttons["Cancel"])
        alert.buttons["Cancel"].tap()
        assertGone(alert)
        assertExists(element(AccessibilityID.Settings.list))
    }
}
