import XCTest

@MainActor
final class OnboardingCommunityViewUITests: AIChatUITestCase {
    func testCommunityShowsItsActivitiesAndAccessibleIllustration() {
        openIntro()
        tap(AccessibilityID.Onboarding.introContinue)
        assertExists(element(AccessibilityID.Onboarding.community))
        for title in ["Discover", "Chat", "Create"] {
            assertExists(app.staticTexts[title])
        }
        let illustration = element(AccessibilityID.Onboarding.communityIllustration)
        assertExists(illustration)
        XCTAssertEqual(illustration.label, "AI characters gathered around a conversation")
    }

    func testContinueOpensColorSelection() {
        openIntro()
        tap(AccessibilityID.Onboarding.introContinue)
        tap(AccessibilityID.Onboarding.communityContinue)
        assertExists(element(AccessibilityID.Onboarding.colorTitle))
        assertGone(element(AccessibilityID.Onboarding.community))
    }
}
