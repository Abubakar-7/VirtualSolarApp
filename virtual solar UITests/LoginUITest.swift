import XCTest

final class LoginUITest: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
        XCUIApplication().launch()
    }

    override func tearDownWithError() throws {}

    func testTapLoginNavigation() throws {
        let app = XCUIApplication()
        app.buttons["loginButton"].tap()

        // Wait for EmailLoginView to appear
        let emailField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(emailField.waitForExistence(timeout: 3), "Failed to navigate to Email Login screen")
    }

    func testTapEmailSignUpNavigation() throws {
        let app = XCUIApplication()
        app.buttons["emailSignUpButton"].tap()

        // Wait for EmailSignUpView to appear
        let nameField = app.textFields.element(boundBy: 0)
        XCTAssertTrue(nameField.waitForExistence(timeout: 3), "Failed to navigate to Email Sign Up screen")
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 18.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
