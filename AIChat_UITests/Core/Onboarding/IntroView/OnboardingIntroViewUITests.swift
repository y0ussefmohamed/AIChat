import XCTest

@MainActor
final class OnboardingIntroViewUITests: AIChatUITestCase {
    func testIntroExplainsAvatarConversations() {
        openIntro()
        assertLabel(element(AccessibilityID.Onboarding.intro), contains: "Make your own avatars")
        assertLabel(element(AccessibilityID.Onboarding.intro), contains: "AI generated responses")
    }

    func testEnabledCommunityExperimentRoutesToCommunity() {
        openIntro()
        tap(AccessibilityID.Onboarding.introContinue)
        assertExists(element(AccessibilityID.Onboarding.community))
        XCTAssertFalse(element(AccessibilityID.Onboarding.colorTitle).exists)
    }

    func testDisabledCommunityExperimentRoutesDirectlyToColors() {
        openIntro(.communityDisabled)
        tap(AccessibilityID.Onboarding.introContinue)
        assertExists(element(AccessibilityID.Onboarding.colorTitle))
        XCTAssertFalse(element(AccessibilityID.Onboarding.community).exists)
    }
}
