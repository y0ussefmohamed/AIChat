import XCTest

@MainActor
final class ImageLoaderViewUITests: AIChatUITestCase {
    func testOfflineAvatarImageIsExposedInProfileModal() {
        openProfileModal()
        let image = app.images[AccessibilityID.Modal.profileImage]
        assertExists(image)
        XCTAssertEqual(image.label, "Avatar profile image")
        XCTAssertGreaterThan(image.frame.width, 0)
        XCTAssertGreaterThan(image.frame.height, 0)
    }
}
