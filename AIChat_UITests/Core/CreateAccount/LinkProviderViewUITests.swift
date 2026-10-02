import XCTest

@MainActor
final class LinkProviderViewUITests: AIChatUITestCase {
    func testSwitchingAccountModeChangesFieldsAndSubmitTitle() {
        openSignIn()
        tap(AccessibilityID.Account.switchMode)
        assertExists(element(AccessibilityID.Account.fullName))
        XCTAssertEqual(element(AccessibilityID.Account.submit).label, "Sign Up")
        tap(AccessibilityID.Account.switchMode)
        assertGone(element(AccessibilityID.Account.fullName))
        XCTAssertEqual(element(AccessibilityID.Account.submit).label, "Sign In")
    }

    func testPasswordVisibilityPreservesEnteredPassword() {
        openSignIn()
        enter("UITestPassword123", into: AccessibilityID.Account.password)
        tap(AccessibilityID.Account.passwordVisibility)
        assertExists(app.textFields[AccessibilityID.Account.password])
        assertValue(app.textFields[AccessibilityID.Account.password], equals: "UITestPassword123")
        XCTAssertEqual(element(AccessibilityID.Account.passwordVisibility).label, "Hide password")
        tap(AccessibilityID.Account.passwordVisibility)
        assertExists(app.secureTextFields[AccessibilityID.Account.password])
        XCTAssertEqual(element(AccessibilityID.Account.passwordVisibility).label, "Show password")
    }

    func testFailedSignInShowsErrorAndKeepsFormValues() {
        openSignIn(.authFailure)
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        enter("UITestPassword123", into: AccessibilityID.Account.password)
        tap(AccessibilityID.Account.submit)
        assertFixtureError()
        dismissAlert("Error")
        assertValue(element(AccessibilityID.Account.email), equals: "uitests@example.com")
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testNewAccountDismissesFormAndKeepsWelcomeForOnboarding() {
        openSignIn()
        tap(AccessibilityID.Account.switchMode)
        enter("UI Test User", into: AccessibilityID.Account.fullName)
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        enter("UITestPassword123", into: AccessibilityID.Account.password)
        dismissKeyboard()
        tap(AccessibilityID.Account.submit)
        assertGone(element(AccessibilityID.Account.fullName))
        assertExists(element(AccessibilityID.Welcome.title))
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testFailedSignUpKeepsCreateAccountFormAndName() {
        openSignIn(.authFailure)
        tap(AccessibilityID.Account.switchMode)
        enter("UI Test User", into: AccessibilityID.Account.fullName)
        enter("uitests@example.com", into: AccessibilityID.Account.email)
        enter("UITestPassword123", into: AccessibilityID.Account.password)
        dismissKeyboard()
        tap(AccessibilityID.Account.submit)
        assertFixtureError()
        dismissAlert("Error")
        assertValue(element(AccessibilityID.Account.fullName), equals: "UI Test User")
        XCTAssertEqual(element(AccessibilityID.Account.title).label, "Create Account")
    }
}
