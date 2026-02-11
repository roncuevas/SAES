import XCTest
@testable import SAES

@MainActor
final class QRScannerViewModelTests: XCTestCase {
    private var sut: QRScannerViewModel!

    override func setUp() {
        super.setUp()
        sut = QRScannerViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - handleScan

    func test_handleScan_setsScannedCode() {
        sut.handleScan("https://example.com/qr")

        XCTAssertEqual(sut.scannedCode, "https://example.com/qr")
        XCTAssertTrue(sut.hasScanned)
    }

    func test_handleScan_ignoresSubsequentScans() {
        sut.handleScan("first-code")
        sut.handleScan("second-code")

        XCTAssertEqual(sut.scannedCode, "first-code")
    }

    // MARK: - submitManualCode

    func test_submitManualCode_returnsTrimmedCode() {
        sut.manualCode = "  test-code  "

        let result = sut.submitManualCode()

        XCTAssertEqual(result, "test-code")
    }

    func test_submitManualCode_returnsNilWhenEmpty() {
        sut.manualCode = "   "

        let result = sut.submitManualCode()

        XCTAssertNil(result)
    }

    func test_submitManualCode_returnsNilWhenBlank() {
        sut.manualCode = ""

        let result = sut.submitManualCode()

        XCTAssertNil(result)
    }

    // MARK: - reset

    func test_reset_clearsAllState() {
        sut.handleScan("code")
        sut.manualCode = "manual"
        sut.showManualEntry = true

        sut.reset()

        XCTAssertEqual(sut.scannedCode, "")
        XCTAssertEqual(sut.manualCode, "")
        XCTAssertFalse(sut.showManualEntry)
        XCTAssertFalse(sut.hasScanned)
    }

    // MARK: - Initial state

    func test_initialState_isClean() {
        XCTAssertEqual(sut.scannedCode, "")
        XCTAssertEqual(sut.manualCode, "")
        XCTAssertFalse(sut.showManualEntry)
        XCTAssertFalse(sut.hasScanned)
    }
}
