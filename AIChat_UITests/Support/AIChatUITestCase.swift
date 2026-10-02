import Foundation
import XCTest

@MainActor
class AIChatUITestCase: XCTestCase {
    enum StartScreen { case welcome, tabs }
    enum ScrollDirection { case up, down }
    let app = XCUIApplication()

    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        #if !MOCK
        throw XCTSkip("UI tests require the AIChat - Mock scheme.")
        #endif
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDownWithError() throws {
        if let testRun, testRun.failureCount > 0, app.state == .runningForeground {
            let screenshot = XCTAttachment(screenshot: app.screenshot())
            screenshot.lifetime = .keepAlways
            add(screenshot)
            let hierarchy = XCTAttachment(string: app.debugDescription)
            hierarchy.lifetime = .keepAlways
            add(hierarchy)
        }
        app.terminate()
        try super.tearDownWithError()
    }

    func launch(_ scenario: UITestScenario = .standard, at start: StartScreen = .tabs) {
        app.terminate()
        app.launchEnvironment["AICHAT_UI_TEST_SCENARIO"] = scenario.rawValue
        app.launchArguments = [
            "--ui-testing", "-showTabbarView", start == .tabs ? "YES" : "NO",
            "-AppleLanguages", "(en)", "-AppleLocale", "en_US"
        ]
        app.launch()
        if start == .welcome {
            assertExists(element(AccessibilityID.Welcome.title))
        } else if scenario == .accountPrompt {
            assertExists(element(AccessibilityID.Account.fullName))
        } else {
            assertExists(element(AccessibilityID.Explore.list))
        }
    }

    func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    func assertExists(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "Missing element: \(element)", file: file, line: line)
    }

    func wait(_ element: XCUIElement, for predicate: NSPredicate, file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed, "Unmet condition: \(predicate)", file: file, line: line)
    }

    func assertGone(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        wait(element, for: NSPredicate(format: "exists == false"), file: file, line: line)
    }

    func assertValue(_ element: XCUIElement, equals value: String, file: StaticString = #filePath, line: UInt = #line) {
        wait(element, for: NSPredicate(format: "value == %@", value), file: file, line: line)
    }

    func assertEmptyField(_ identifier: String, placeholder: String, file: StaticString = #filePath, line: UInt = #line) {
        let field = element(identifier)
        assertExists(field, file: file, line: line)
        // UIKit exposes an empty field as nil, an empty string, or its placeholder depending on the OS.
        wait(field, for: NSPredicate(format: "placeholderValue == %@ AND (value == nil OR value == '' OR value == %@)", placeholder, placeholder), file: file, line: line)
    }

    func assertLabel(_ element: XCUIElement, contains text: String, file: StaticString = #filePath, line: UInt = #line) {
        wait(element, for: NSPredicate(format: "label CONTAINS %@", text), file: file, line: line)
    }

    func tap(_ identifier: String, file: StaticString = #filePath, line: UInt = #line) {
        let target = element(identifier)
        assertExists(target, file: file, line: line)
        wait(target, for: NSPredicate(format: "hittable == true"), file: file, line: line)
        target.tap()
    }

    func enter(_ text: String, into identifier: String) {
        tap(identifier)
        element(identifier).typeText(text)
    }

    func scrollTo(_ identifier: String, in container: String, direction: ScrollDirection = .up) {
        let scrollView = element(container)
        assertExists(scrollView)
        let target = element(identifier)
        for _ in 0..<6 {
            if target.exists && target.isHittable { return }
            if direction == .up {
                scrollView.swipeUp()
            } else {
                scrollView.swipeDown()
            }
        }
        XCTAssertTrue(target.exists && target.isHittable, "Could not reveal \(identifier) in \(container)")
    }

    func swipeTo(_ identifier: String, in carousel: String) {
        let scrollView = element(carousel)
        assertExists(scrollView)
        let target = element(identifier)
        for _ in 0..<4 {
            if target.exists && target.isHittable { return }
            scrollView.swipeLeft()
        }
        XCTAssertTrue(target.exists && target.isHittable, "Could not reveal \(identifier) in \(carousel)")
    }

    func dismissKeyboard() {
        let keyboard = app.keyboards.firstMatch
        guard keyboard.exists else { return }
        // Return is a platform keyboard action, rather than an app control.
        let returnKey = keyboard.buttons["Return"]
        assertExists(returnKey)
        returnKey.tap()
    }

    func assertFixtureError() {
        let alert = app.alerts["Error"]
        assertExists(alert)
        XCTAssertTrue(alert.staticTexts[UITestFixture.failure].exists)
    }

    func dismissAlert(_ title: String) {
        let alert = app.alerts[title]
        assertExists(alert)
        alert.buttons["OK"].tap()
        assertGone(alert)
    }

    func choose(_ option: String, in picker: String, value: String? = nil) {
        tap(picker)
        // SwiftUI menus and system alerts expose their native action labels.
        let choice = app.buttons[option]
        assertExists(choice)
        choice.tap()
        assertValue(element(picker), equals: value ?? option)
    }

    func message(_ content: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(
            format: "identifier BEGINSWITH %@ AND label == %@",
            AccessibilityID.Chat.messagePrefix, content
        )).firstMatch
    }
}
