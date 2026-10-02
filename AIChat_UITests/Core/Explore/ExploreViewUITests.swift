import XCTest

@MainActor
final class ExploreViewUITests: AIChatUITestCase {
    func testExploreShowsLoadedFeaturedPopularAndCategorySections() {
        launch()
        for id in [AccessibilityID.Explore.featuredTitle, AccessibilityID.Explore.categoriesTitle, AccessibilityID.Explore.popularTitle] {
            scrollTo(id, in: AccessibilityID.Explore.list)
            assertExists(element(id))
        }
        XCTAssertFalse(app.progressIndicators.firstMatch.exists)
    }

    func testPopularAvatarOpensItsConversation() {
        launch()
        let row = AccessibilityID.Explore.popular(UITestFixture.betaId)
        scrollTo(row, in: AccessibilityID.Explore.list)
        tap(row)
        assertExists(element(AccessibilityID.Chat.composer))
        assertExists(message(UITestFixture.betaGreeting))
    }

    func testCategoriesCanBeHiddenByExperiment() {
        launch(.categoriesHidden)
        assertExists(element(AccessibilityID.Explore.featured(UITestFixture.alphaId)))
        XCTAssertFalse(element(AccessibilityID.Explore.categories).exists)
    }

    func testCategoriesCanAppearAboveFeaturedSection() {
        launch(.categoriesTop)
        let categories = element(AccessibilityID.Explore.categoriesTitle)
        let featured = element(AccessibilityID.Explore.featuredTitle)
        assertExists(categories)
        assertExists(featured)
        XCTAssertLessThan(categories.frame.minY, featured.frame.minY)
    }

    func testAnonymousAccountExperimentPresentsCreateAccount() {
        launch(.accountPrompt)
        assertExists(element(AccessibilityID.Account.fullName))
        XCTAssertEqual(element(AccessibilityID.Account.title).label, "Create Account")
    }

    func testNotificationPromptCanBeDeclinedWithoutChangingAuthorization() {
        launch()
        tap(AccessibilityID.Explore.notifications)
        tap(AccessibilityID.Modal.secondary(AccessibilityID.Modal.notifications))
        assertGone(element(AccessibilityID.Modal.title(AccessibilityID.Modal.notifications)))
        assertExists(element(AccessibilityID.Explore.notifications))
    }

    func testEnablingMockNotificationsRemovesPromptButton() {
        launch()
        tap(AccessibilityID.Explore.notifications)
        tap(AccessibilityID.Modal.primary(AccessibilityID.Modal.notifications))
        assertGone(element(AccessibilityID.Explore.notifications))
        assertExists(element(AccessibilityID.Explore.list))
        XCTAssertFalse(app.alerts.firstMatch.exists)
    }

    func testDeniedNotificationsDoNotShowAuthorizationPrompt() {
        launch(.notificationsDenied)
        assertExists(element(AccessibilityID.Explore.featured(UITestFixture.alphaId)))
        assertGone(element(AccessibilityID.Explore.notifications))
    }
}
