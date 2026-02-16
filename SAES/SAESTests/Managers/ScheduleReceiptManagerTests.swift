import XCTest
@testable import SAES

@MainActor
final class ScheduleReceiptManagerTests: XCTestCase {
    private var mockDataSource: MockSAESDataSource!
    private var mockStorage: MockLocalStorageClient!
    private var sut: ScheduleReceiptManager!

    private let testSchoolCode = "testSchool"
    private let testStudentID = "2020601234"

    private static let cachesDirectory: URL = {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }()

    private static func expectedFileURL(for studentID: String) -> URL {
        cachesDirectory.appendingPathComponent("\(studentID)_comprobante", conformingTo: .pdf)
    }

    override func setUp() async throws {
        try await super.setUp()
        mockDataSource = MockSAESDataSource()
        mockStorage = MockLocalStorageClient()
        UserDefaults.standard.set(testSchoolCode, forKey: AppConstants.UserDefaultsKeys.schoolCode)
    }

    override func tearDown() async throws {
        let fileURL = Self.expectedFileURL(for: testStudentID)
        try? FileManager.default.removeItem(at: fileURL)
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.schoolCode)
        mockDataSource = nil
        mockStorage = nil
        sut = nil
        try await super.tearDown()
    }

    private func makeSUT() -> ScheduleReceiptManager {
        ScheduleReceiptManager(
            dataSource: mockDataSource,
            storage: mockStorage
        )
    }

    private func seedUser(studentID: String = "2020601234") {
        mockStorage.storedUsers[testSchoolCode] = LocalUserModel(
            schoolCode: testSchoolCode,
            studentID: studentID,
            password: "encrypted",
            ivValue: "iv",
            cookie: []
        )
    }

    private func createTestPDF(for studentID: String) {
        let data = Data("%PDF-1.4 test".utf8)
        let url = Self.expectedFileURL(for: studentID)
        try? data.write(to: url)
    }

    // MARK: - fileName

    func test_fileName_whenNoUser_returnsNil() {
        sut = makeSUT()

        XCTAssertNil(sut.fileName)
    }

    func test_fileName_whenUserExists_returnsCorrectFormat() {
        seedUser()
        sut = makeSUT()

        XCTAssertEqual(sut.fileName, "\(testStudentID)_comprobante.pdf")
    }

    // MARK: - hasCachedPDF

    func test_hasCachedPDF_whenNoUser_returnsFalse() {
        sut = makeSUT()

        XCTAssertFalse(sut.hasCachedPDF)
    }

    func test_hasCachedPDF_whenUserExistsButNoFile_returnsFalse() {
        seedUser()
        sut = makeSUT()

        XCTAssertFalse(sut.hasCachedPDF)
    }

    func test_hasCachedPDF_whenFileExists_returnsTrue() {
        seedUser()
        createTestPDF(for: testStudentID)
        sut = makeSUT()

        XCTAssertTrue(sut.hasCachedPDF)
    }

    func test_hasCachedPDF_usesStorageToResolveStudentID() {
        seedUser()
        sut = makeSUT()

        _ = sut.hasCachedPDF

        XCTAssertEqual(mockStorage.loadUserCallCount, 1)
    }

    // MARK: - showCachedPDF

    func test_showCachedPDF_whenNoUser_doesNotSetURL() {
        sut = makeSUT()

        sut.showCachedPDF()

        XCTAssertNil(sut.pdfURL)
    }

    func test_showCachedPDF_whenNoFile_doesNotSetURL() {
        seedUser()
        sut = makeSUT()

        sut.showCachedPDF()

        XCTAssertNil(sut.pdfURL)
    }

    func test_showCachedPDF_whenFileExists_setsURL() {
        seedUser()
        createTestPDF(for: testStudentID)
        sut = makeSUT()

        sut.showCachedPDF()

        XCTAssertNotNil(sut.pdfURL)
        XCTAssertEqual(sut.pdfURL, Self.expectedFileURL(for: testStudentID))
    }

    // MARK: - getPDFData

    func test_getPDFData_withoutSession_doesNotFetch() async {
        seedUser()
        sut = makeSUT()

        await sut.getPDFData()

        // getPDFData uses UserSessionManager.shared for async studentID resolution.
        // Without a real session, it returns early before fetching.
        XCTAssertEqual(mockDataSource.fetchCallCount, 0)
        XCTAssertNil(sut.pdfURL)
    }

    // MARK: - deleteReceipt

    func test_deleteReceipt_whenNoUser_doesNothing() {
        sut = makeSUT()

        sut.deleteReceipt()

        XCTAssertNil(sut.pdfURL)
    }

    func test_deleteReceipt_removesFileAndClearsURL() {
        seedUser()
        createTestPDF(for: testStudentID)
        sut = makeSUT()
        sut.showCachedPDF()
        XCTAssertNotNil(sut.pdfURL)

        sut.deleteReceipt()

        XCTAssertNil(sut.pdfURL)
        XCTAssertFalse(FileManager.default.fileExists(atPath: Self.expectedFileURL(for: testStudentID).path))
    }

    func test_deleteReceipt_whenFileDoesNotExist_stillClearsURL() {
        seedUser()
        sut = makeSUT()

        sut.deleteReceipt()

        XCTAssertNil(sut.pdfURL)
        XCTAssertFalse(sut.hasCachedPDF)
    }

    // MARK: - Per-school isolation

    func test_differentStudents_haveDifferentFiles() {
        let studentA = "2020601111"
        let studentB = "2020602222"
        createTestPDF(for: studentA)

        seedUser(studentID: studentA)
        sut = makeSUT()
        XCTAssertTrue(sut.hasCachedPDF)

        mockStorage.storedUsers[testSchoolCode] = LocalUserModel(
            schoolCode: testSchoolCode,
            studentID: studentB,
            password: "encrypted",
            ivValue: "iv",
            cookie: []
        )
        XCTAssertFalse(sut.hasCachedPDF)

        // Clean up extra file
        try? FileManager.default.removeItem(at: Self.expectedFileURL(for: studentA))
    }

    // MARK: - Icon constant

    func test_icon_returnsExpectedValue() {
        XCTAssertEqual(ScheduleReceiptManager.icon, "doc.text")
    }
}
