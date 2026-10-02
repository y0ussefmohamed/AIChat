import Foundation
import XCTest

@MainActor
final class AsyncCallToActionButtonUITests: AIChatUITestCase {
    func testFinishDisablesWhileLoadingAndCompletesOnce() {
        openCompleted(.slowOnboarding)
        tap(AccessibilityID.Onboarding.finish)
        let finish = element(AccessibilityID.Onboarding.finish)
        assertValue(finish, equals: "Loading")
        XCTAssertFalse(finish.isEnabled)
        assertExists(element(AccessibilityID.Explore.list))
        assertGone(finish)
    }

    func testSaveDisablesDuringStorageAndDismissesAfterSuccess() {
        openCreateAvatar(.slowAvatarSave)
        prepareAvatar(named: "Slow Save Avatar")
        tap(AccessibilityID.CreateAvatar.save)
        let save = element(AccessibilityID.CreateAvatar.save)
        assertValue(save, equals: "Loading")
        XCTAssertFalse(save.isEnabled)
        assertGone(element(AccessibilityID.CreateAvatar.list))
        assertExists(element(AccessibilityID.Profile.list))
    }
}
