import XCTest

@MainActor
final class WelcomeViewUITests: AIChatUITestCase {
    func testWelcomeOffersOnboardingSignInAndPolicies() {
        launch(at: .welcome)
        XCTAssertEqual(element(AccessibilityID.Welcome.title).label, "AI Chat 📱")
        for id in [AccessibilityID.Welcome.getStarted, AccessibilityID.Welcome.signIn, AccessibilityID.Welcome.terms, AccessibilityID.Welcome.privacy] {
            assertExists(element(id))
        }
        XCTAssertFalse(app.tabBars.firstMatch.exists)
    }

    func testGetStartedOpensIntro() {
        launch(at: .welcome)
        tap(AccessibilityID.Welcome.getStarted)
        assertExists(element(AccessibilityID.Onboarding.intro))
        assertExists(element(AccessibilityID.Onboarding.introContinue))
    }

    func testSignInPresentsExistingAccountForm() {
        openSignIn()
        XCTAssertEqual(element(AccessibilityID.Account.title).label, "Sign In")
        assertExists(app.secureTextFields[AccessibilityID.Account.password])
        XCTAssertFalse(element(AccessibilityID.Account.fullName).exists)
    }
}
