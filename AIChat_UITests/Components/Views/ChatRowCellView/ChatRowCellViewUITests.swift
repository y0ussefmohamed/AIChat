import XCTest

@MainActor
final class ChatRowCellViewUITests: AIChatUITestCase {
    func testResolvedRowsExposeTheirNameLastMessageAndReadStatus() {
        launch()
        selectTab("Chats")
        let alpha = element(AccessibilityID.Chats.row(UITestFixture.alphaChatId))
        let beta = element(AccessibilityID.Chats.row(UITestFixture.betaChatId))
        assertLabel(alpha, contains: UITestFixture.greeting)
        assertLabel(alpha, contains: "Unread")
        assertLabel(beta, contains: UITestFixture.betaGreeting)
        assertLabel(beta, contains: "Read")
    }
}
