@testable import SAES
import XCTest

final class VersionComparerTests: XCTestCase {

    // MARK: - Older versions

    func testOlderMajor() {
        XCTAssertTrue(VersionComparer.isOlderThan(current: "1.0.0", minimum: "2.0.0"))
    }

    func testOlderMinor() {
        XCTAssertTrue(VersionComparer.isOlderThan(current: "2.0.0", minimum: "2.1.0"))
    }

    func testOlderPatch() {
        XCTAssertTrue(VersionComparer.isOlderThan(current: "2.1.0", minimum: "2.1.1"))
    }

    // MARK: - Equal versions

    func testEqualVersions() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "2.1.0", minimum: "2.1.0"))
    }

    // MARK: - Newer versions

    func testNewerMajor() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "3.0.0", minimum: "2.0.0"))
    }

    func testNewerMinor() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "2.2.0", minimum: "2.1.0"))
    }

    func testNewerPatch() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "2.1.2", minimum: "2.1.1"))
    }

    // MARK: - Missing components

    func testMissingPatchTreatedAsZero() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "2.0", minimum: "2.0.0"))
    }

    func testMissingPatchOnMinimum() {
        XCTAssertTrue(VersionComparer.isOlderThan(current: "1.9.9", minimum: "2.0"))
    }

    func testTwoComponentsEqual() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "2.0", minimum: "2.0"))
    }

    // MARK: - Empty minimum

    func testEmptyMinimumReturnsFalse() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "1.0.0", minimum: ""))
    }

    func testEmptyBothReturnsFalse() {
        XCTAssertFalse(VersionComparer.isOlderThan(current: "", minimum: ""))
    }
}
