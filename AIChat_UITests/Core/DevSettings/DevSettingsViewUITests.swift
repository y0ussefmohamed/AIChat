import XCTest

@MainActor
final class DevSettingsViewUITests: AIChatUITestCase {
    func testMockExperimentsAreEditableAndRetainOverrideInCurrentProcess() {
        launch()
        tap(AccessibilityID.Explore.developerSettings)
        let community = element(AccessibilityID.DeveloperSettings.community)
        assertValue(community, equals: "1")
        // On recent iOS versions the identified toggle row contains the actual switch control.
        let control = community.switches.firstMatch
        if control.exists {
            control.tap()
        } else {
            community.tap()
        }
        assertValue(community, equals: "0")
        tap(AccessibilityID.DeveloperSettings.close)
        tap(AccessibilityID.Explore.developerSettings)
        assertValue(element(AccessibilityID.DeveloperSettings.community), equals: "0")
    }

    func testCategoryOverrideChangesExploreLayout() {
        launch()
        tap(AccessibilityID.Explore.developerSettings)
        choose("Hidden", in: AccessibilityID.DeveloperSettings.categoryRow, value: "hidden")
        tap(AccessibilityID.DeveloperSettings.close)
        assertGone(element(AccessibilityID.Explore.categories))
        assertExists(element(AccessibilityID.Explore.featured(UITestFixture.alphaId)))
    }

    func testCloseReturnsToExplore() {
        launch()
        tap(AccessibilityID.Explore.developerSettings)
        assertExists(element(AccessibilityID.DeveloperSettings.list))
        tap(AccessibilityID.DeveloperSettings.close)
        assertGone(element(AccessibilityID.DeveloperSettings.list))
        assertExists(element(AccessibilityID.Explore.list))
    }
}
