import XCTest

@MainActor
final class ProfileViewUITests: AIChatUITestCase {
    func testProfileLoadsOwnedAvatarsAndAccountControls() {
        openProfile()
        for id in ["alpha", "beta", "gamma", "delta"] {
            let row = AccessibilityID.Profile.avatar(id)
            scrollTo(row, in: AccessibilityID.Profile.list)
            assertExists(element(row))
        }
        assertExists(element(AccessibilityID.Profile.settings))
        XCTAssertFalse(element(AccessibilityID.Profile.empty).exists)
    }

    func testEmptyProfileOffersAvatarCreation() {
        openProfile(.emptyProfile)
        assertExists(element(AccessibilityID.Profile.empty))
        tap(AccessibilityID.Profile.emptyCreate)
        assertExists(element(AccessibilityID.CreateAvatar.name))
    }

    func testDeletingAvatarRemovesItAfterProfileReloads() {
        openProfile()
        let list = element(AccessibilityID.Profile.list)
        let row = element(AccessibilityID.Profile.avatar(UITestFixture.alphaId))
        assertExists(row)
        let cell = list.cells.containing(.button, identifier: AccessibilityID.Profile.avatar(UITestFixture.alphaId)).firstMatch
        assertExists(cell)
        cell.swipeLeft()
        app.buttons["Delete"].tap()
        assertGone(row)
        tap(AccessibilityID.Profile.settings)
        assertExists(element(AccessibilityID.Settings.list))
        // Return to a fresh root launch would reset fixtures; a sheet dismissal reloads this process's data.
        let settingsNavigation = app.navigationBars["Settings"]
        assertExists(settingsNavigation)
        settingsNavigation.swipeDown()
        assertGone(element(AccessibilityID.Settings.list))
        assertExists(element(AccessibilityID.Profile.avatar(UITestFixture.betaId)))
        XCTAssertFalse(row.exists)
    }

    func testProfileLoadFailureShowsErrorAndEmptyState() {
        openProfile(.profileFailure)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Profile.empty))
        XCTAssertFalse(element(AccessibilityID.Profile.avatar(UITestFixture.alphaId)).exists)
    }
}
