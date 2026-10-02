import Foundation
import XCTest

@MainActor
final class CreateAvatarViewUITests: AIChatUITestCase {
    func testSaveWithoutNameOrImageDoesNotSubmit() {
        openCreateAvatar()
        scrollTo(AccessibilityID.CreateAvatar.save, in: AccessibilityID.CreateAvatar.list)
        tap(AccessibilityID.CreateAvatar.save)
        assertExists(element(AccessibilityID.CreateAvatar.list))
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    func testAttributePickersUpdateSelectedValues() {
        openCreateAvatar()
        choose("alien", in: AccessibilityID.CreateAvatar.character)
        choose("smiling", in: AccessibilityID.CreateAvatar.action)
        choose("park", in: AccessibilityID.CreateAvatar.location)
        assertValue(element(AccessibilityID.CreateAvatar.character), equals: "alien")
        assertValue(element(AccessibilityID.CreateAvatar.action), equals: "smiling")
        assertValue(element(AccessibilityID.CreateAvatar.location), equals: "park")
    }

    func testSavingGeneratedAvatarAddsItToProfile() {
        openCreateAvatar()
        let name = "UI Test Avatar"
        prepareAvatar(named: name)
        tap(AccessibilityID.CreateAvatar.save)
        assertGone(element(AccessibilityID.CreateAvatar.list))
        let created = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'profile.avatar.' AND label CONTAINS %@", name)).firstMatch
        assertExists(created)
        created.tap()
        assertExists(app.navigationBars[name])
        assertExists(element(AccessibilityID.Chat.composer))
    }

    func testOneCharacterNameShowsValidationAndAllowsCorrection() {
        openCreateAvatar()
        prepareAvatar(named: "A")
        tap(AccessibilityID.CreateAvatar.save)
        dismissAlert("Name your avatar")
        XCTAssertTrue(element(AccessibilityID.CreateAvatar.save).isEnabled)
        scrollTo(AccessibilityID.CreateAvatar.name, in: AccessibilityID.CreateAvatar.list, direction: .down)
        enter("lpha", into: AccessibilityID.CreateAvatar.name)
        dismissKeyboard()
        scrollTo(AccessibilityID.CreateAvatar.save, in: AccessibilityID.CreateAvatar.list)
        tap(AccessibilityID.CreateAvatar.save)
        assertGone(element(AccessibilityID.CreateAvatar.list))
    }

    func testSaveFailureKeepsGeneratedImageAndFormOpen() {
        openCreateAvatar(.avatarSaveFailure)
        prepareAvatar(named: "UI Test Avatar")
        tap(AccessibilityID.CreateAvatar.save)
        assertFixtureError()
        dismissAlert("Error")
        assertExists(element(AccessibilityID.CreateAvatar.generatedImage))
        XCTAssertTrue(element(AccessibilityID.CreateAvatar.save).isEnabled)
    }

    func testImageFailureRestoresGenerateControlWithoutImage() {
        openCreateAvatar(.imageFailure)
        tap(AccessibilityID.CreateAvatar.generate)
        assertExists(element(AccessibilityID.CreateAvatar.generating))
        assertGone(element(AccessibilityID.CreateAvatar.generating))
        assertExists(element(AccessibilityID.CreateAvatar.generate))
        XCTAssertFalse(element(AccessibilityID.CreateAvatar.generatedImage).exists)
    }

    func testClosingAndReopeningResetsUnsavedName() {
        openCreateAvatar()
        enter("Unsaved Avatar", into: AccessibilityID.CreateAvatar.name)
        tap(AccessibilityID.CreateAvatar.close)
        assertGone(element(AccessibilityID.CreateAvatar.list))
        tap(AccessibilityID.Profile.createAvatar)
        assertEmptyField(AccessibilityID.CreateAvatar.name, placeholder: "Enter Avatar Name")
        XCTAssertFalse(element(AccessibilityID.CreateAvatar.generatedImage).exists)
    }
}
