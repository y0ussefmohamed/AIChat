import XCTest

@MainActor
final class CustomTextFieldUITests: AIChatUITestCase {
    func testFullNameAndEmailFieldsStoreIndependentValues() {
        openSignIn()
        tap(AccessibilityID.Account.switchMode)
        enter("UI Test User", into: AccessibilityID.Account.fullName)
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        assertValue(element(AccessibilityID.Account.fullName), equals: "UI Test User")
        assertValue(element(AccessibilityID.Account.email), equals: "uitests@example.com")
    }

    func testSwitchingFormModePreservesEmail() {
        openSignIn()
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        dismissKeyboard()
        tap(AccessibilityID.Account.switchMode)
        assertValue(element(AccessibilityID.Account.email), equals: "uitests@example.com")
        tap(AccessibilityID.Account.switchMode)
        assertValue(element(AccessibilityID.Account.email), equals: "uitests@example.com")
    }
}
