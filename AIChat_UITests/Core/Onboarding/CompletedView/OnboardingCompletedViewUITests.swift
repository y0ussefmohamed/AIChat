import XCTest

@MainActor
final class OnboardingCompletedViewUITests: AIChatUITestCase {
    func testFinishSavesSelectedColorAndOpensMainScreen() {
        openCompleted()
        let expectedColor = element(AccessibilityID.Onboarding.completed).value as? String
        XCTAssertNotNil(expectedColor)
        tap(AccessibilityID.Onboarding.finish)
        assertExists(element(AccessibilityID.Explore.list))
        selectTab("Profile")
        assertExists(element(AccessibilityID.Profile.color))
        assertValue(element(AccessibilityID.Profile.color), equals: expectedColor ?? "")
    }

    func testFailedSetupKeepsCompletionScreenAndRestoresFinishButton() {
        openCompleted(.onboardingFailure)
        tap(AccessibilityID.Onboarding.finish)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.Onboarding.completed))
        XCTAssertTrue(element(AccessibilityID.Onboarding.finish).isEnabled)
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }
}
