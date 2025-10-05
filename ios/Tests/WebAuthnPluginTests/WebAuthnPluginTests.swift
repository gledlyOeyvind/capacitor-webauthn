import XCTest
@testable import WebAuthnPlugin

class WebAuthnPluginTests: XCTestCase {
    func testIsAvailable() {
        // This is an example of a functional test case for a plugin.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        if #available(iOS 15.0, *) {
            let implementation = WebAuthn()
            let result = implementation.isAvailable()

            XCTAssertTrue(result)
        }
    }
}
