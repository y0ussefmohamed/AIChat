import XCTest

@MainActor
extension AIChatUITestCase {
    func selectTab(_ title: String) {
        // System tab items have stable visible titles; content controls use shared identifiers.
        let tab = app.tabBars.buttons[title]
        assertExists(tab)
        tab.tap()
    }

    func openSignIn(_ scenario: UITestScenario = .standard) {
        launch(scenario, at: .welcome)
        tap(AccessibilityID.Welcome.signIn)
        assertExists(element(AccessibilityID.Account.email))
    }

    func openIntro(_ scenario: UITestScenario = .standard) {
        launch(scenario, at: .welcome)
        tap(AccessibilityID.Welcome.getStarted)
        assertExists(element(AccessibilityID.Onboarding.intro))
    }

    func openColor(_ scenario: UITestScenario = .standard) {
        openIntro(scenario)
        tap(AccessibilityID.Onboarding.introContinue)
        if scenario != .communityDisabled {
            assertExists(element(AccessibilityID.Onboarding.community))
            tap(AccessibilityID.Onboarding.communityContinue)
        }
        assertExists(element(AccessibilityID.Onboarding.colorTitle))
    }

    func openCompleted(_ scenario: UITestScenario = .standard) {
        openColor(scenario)
        tap(AccessibilityID.Onboarding.color(0))
        tap(AccessibilityID.Onboarding.colorContinue)
        assertExists(element(AccessibilityID.Onboarding.completed))
    }

    func openProfile(_ scenario: UITestScenario = .standard) {
        launch(scenario)
        selectTab("Profile")
        if scenario == .profileFailure {
            assertExists(app.alerts["Error"])
        } else {
            assertExists(element(AccessibilityID.Profile.list))
        }
    }

    func openSettings(_ scenario: UITestScenario = .standard) {
        openProfile(scenario)
        tap(AccessibilityID.Profile.settings)
        assertExists(element(AccessibilityID.Settings.list))
    }

    func openCreateAvatar(_ scenario: UITestScenario = .standard) {
        openProfile(scenario)
        tap(AccessibilityID.Profile.createAvatar)
        assertExists(element(AccessibilityID.CreateAvatar.name))
    }

    func openChat(_ scenario: UITestScenario = .standard, avatarId: String = UITestFixture.alphaId) {
        openProfile(scenario)
        let row = AccessibilityID.Profile.avatar(avatarId)
        scrollTo(row, in: AccessibilityID.Profile.list)
        tap(row)
        assertExists(element(AccessibilityID.Chat.composer))
    }

    func openCategory(_ scenario: UITestScenario = .standard) {
        launch(scenario)
        swipeTo(AccessibilityID.Explore.category("alien"), in: AccessibilityID.Explore.categories)
        tap(AccessibilityID.Explore.category("alien"))
        if scenario == .categoryFailure {
            assertExists(app.alerts["Error"])
        } else {
            assertExists(element(AccessibilityID.Category.list))
        }
    }

    func openRatingsModal() {
        openSettings()
        scrollTo(AccessibilityID.Settings.rating, in: AccessibilityID.Settings.list)
        tap(AccessibilityID.Settings.rating)
        assertExists(element(AccessibilityID.Modal.title(AccessibilityID.Modal.rating)))
    }

    func openProfileModal(_ scenario: UITestScenario = .standard) {
        openChat(scenario)
        if scenario == .emptyConversation {
            tap(AccessibilityID.Chat.emptyAvatar)
        } else {
            tap(AccessibilityID.Chat.avatarImage(UITestFixture.greetingId))
        }
        assertExists(element(AccessibilityID.Modal.profileClose))
    }

    func generateImage() {
        scrollTo(AccessibilityID.CreateAvatar.generate, in: AccessibilityID.CreateAvatar.list)
        tap(AccessibilityID.CreateAvatar.generate)
        assertExists(element(AccessibilityID.CreateAvatar.generatedImage))
        assertGone(element(AccessibilityID.CreateAvatar.generating))
    }

    func prepareAvatar(named name: String) {
        enter(name, into: AccessibilityID.CreateAvatar.name)
        dismissKeyboard()
        generateImage()
        scrollTo(AccessibilityID.CreateAvatar.save, in: AccessibilityID.CreateAvatar.list)
    }

    func send(_ text: String) {
        enter(text, into: AccessibilityID.Chat.composer)
        tap(AccessibilityID.Chat.send)
    }

    func chatAction(_ title: String) {
        tap(AccessibilityID.Chat.actions)
        let action = app.buttons[title]
        assertExists(action)
        action.tap()
    }
}
