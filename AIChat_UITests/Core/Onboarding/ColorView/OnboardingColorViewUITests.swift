import XCTest

@MainActor
final class OnboardingColorViewUITests: AIChatUITestCase {
    func testContinueRequiresAColorSelection() {
        openColor()
        XCTAssertFalse(element(AccessibilityID.Onboarding.colorContinue).exists)
        tap(AccessibilityID.Onboarding.color(0))
        assertValue(element(AccessibilityID.Onboarding.color(0)), equals: "Selected")
        assertExists(element(AccessibilityID.Onboarding.colorContinue))
    }

    func testSelectingAnotherColorClearsPreviousSelection() {
        openColor()
        tap(AccessibilityID.Onboarding.color(0))
        tap(AccessibilityID.Onboarding.color(1))
        assertValue(element(AccessibilityID.Onboarding.color(0)), equals: "Not selected")
        assertValue(element(AccessibilityID.Onboarding.color(1)), equals: "Selected")
        tap(AccessibilityID.Onboarding.colorContinue)
        assertExists(element(AccessibilityID.Onboarding.completed))
    }

    func testAllNineColorsAreAccessibleButtons() {
        openColor()
        for index in 0..<9 {
            let id = AccessibilityID.Onboarding.color(index)
            let button = app.buttons[id]
            assertExists(button)
            XCTAssertFalse(button.label.isEmpty)
            tap(id)
            assertValue(button, equals: "Selected")
        }
    }
}
