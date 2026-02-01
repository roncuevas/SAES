import XCTest
@testable import SAES

final class StringExtensionTests: XCTestCase {

    func testConvertDataURIToData() {
        let base64 = "SGVsbG8="
        let dataURI = "data:text/plain;base64,\(base64)"
        let result = dataURI.convertDataURIToData()
        XCTAssertNotNil(result)
        XCTAssertEqual(String(data: result!, encoding: .utf8), "Hello")
    }

    func testConvertDataURIToDataReturnsNilWithoutComma() {
        let invalid = "nocommahere"
        XCTAssertNil(invalid.convertDataURIToData())
    }

    func testColon() {
        XCTAssertEqual("test".colon, "test:")
    }

    func testSpace() {
        XCTAssertEqual("test".space, "test ")
    }

    func testDash() {
        XCTAssertEqual("test".dash, "test-")
    }

    func testSha256() {
        let hash = "hello".sha256
        XCTAssertEqual(hash, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    func testEventEmoji() {
        XCTAssertEqual("vacations".eventEmoji, "🌴")
        XCTAssertEqual("day_off".eventEmoji, "🎉")
        XCTAssertEqual("unknown".eventEmoji, "❓")
    }
}
