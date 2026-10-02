import XCTest

@MainActor
final class SettingsViewUITests: AIChatUITestCase {
    func testSettingsShowsAccountPurchaseAndAppInformation() {
        openSettings()
        for id in [AccessibilityID.Settings.signOut, AccessibilityID.Settings.deleteAccount, AccessibilityID.Settings.premium, AccessibilityID.Settings.manage, AccessibilityID.Settings.version, AccessibilityID.Settings.build, AccessibilityID.Settings.contact] {
            scrollTo(id, in: AccessibilityID.Settings.list)
            assertExists(element(id))
        }
        assertLabel(element(AccessibilityID.Settings.premium), contains: "Premium")
    }

    func testSignOutReturnsToWelcome() {
        openSettings()
        tap(AccessibilityID.Settings.signOut)
        assertExists(element(AccessibilityID.Welcome.title))
        assertGone(app.tabBars.firstMatch)
    }

    func testSignOutFailureKeepsSettingsOpen() {
        openSettings(.signOutFailure)
        tap(AccessibilityID.Settings.signOut)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Settings.signOut))
        assertExists(element(AccessibilityID.Settings.list))
    }

    func testAccountDeletionCanBeCancelled() {
        openSettings()
        tap(AccessibilityID.Settings.deleteAccount)
        let alert = app.alerts["Delete Account?"]
        assertExists(alert)
        alert.buttons["Cancel"].tap()
        assertGone(alert)
        assertExists(element(AccessibilityID.Settings.signOut))
    }

    func testConfirmedDeletionReturnsToWelcome() {
        openSettings()
        tap(AccessibilityID.Settings.deleteAccount)
        let delete = app.alerts["Delete Account?"].buttons["Delete"]
        assertExists(delete)
        delete.tap()
        assertExists(element(AccessibilityID.Welcome.title))
        assertGone(app.tabBars.firstMatch)
    }

    func testDeletionFailureShowsErrorRatherThanLeavingSettings() {
        openSettings(.deleteAccountFailure)
        tap(AccessibilityID.Settings.deleteAccount)
        app.alerts["Delete Account?"].buttons["Delete"].tap()
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Settings.list))
        XCTAssertFalse(element(AccessibilityID.Welcome.title).exists)
    }

    func testAnonymousAccountCanOpenBackupForm() {
        openSettings(.anonymous)
        assertExists(element(AccessibilityID.Settings.backup))
        XCTAssertFalse(element(AccessibilityID.Settings.signOut).exists)
        tap(AccessibilityID.Settings.backup)
        assertExists(element(AccessibilityID.Account.fullName))
        XCTAssertEqual(element(AccessibilityID.Account.title).label, "Create Account")
    }
}
