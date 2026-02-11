import XCTest
@testable import SAES

@MainActor
final class CredentialViewModelTests: XCTestCase {
    private var mockStorage: MockCredentialStorageClient!
    private var mockDataSource: MockSAESDataSource!
    private var mockProfilePictureDataSource: MockSAESDataSource!
    private var sut: CredentialViewModel!

    override func setUp() {
        super.setUp()
        mockStorage = MockCredentialStorageClient()
        mockDataSource = MockSAESDataSource()
        mockProfilePictureDataSource = MockSAESDataSource()
    }

    override func tearDown() {
        mockStorage = nil
        mockDataSource = nil
        mockProfilePictureDataSource = nil
        sut = nil
        super.tearDown()
    }

    private func makeSUT(schoolCode: String = "escom") -> CredentialViewModel {
        CredentialViewModel(
            storage: mockStorage,
            dataSource: mockDataSource,
            profilePictureDataSource: mockProfilePictureDataSource,
            schoolCodeProvider: { schoolCode }
        )
    }

    // MARK: - loadSavedCredential

    func test_loadSavedCredential_whenNoCredential_setsNil() {
        sut = makeSUT()

        sut.loadSavedCredential()

        XCTAssertNil(sut.credentialModel)
        XCTAssertFalse(sut.hasCredential)
        XCTAssertEqual(mockStorage.loadCallCount, 1)
    }

    func test_loadSavedCredential_whenCredentialExists_loadsIt() {
        let credential = makeTestCredential(schoolCode: "escom")
        mockStorage.storedCredentials["escom"] = credential
        sut = makeSUT()

        sut.loadSavedCredential()

        XCTAssertNotNil(sut.credentialModel)
        XCTAssertTrue(sut.hasCredential)
        XCTAssertEqual(sut.credentialModel?.qrData, "test-qr-data")
    }

    // MARK: - saveQRData

    func test_saveQRData_persistsAndUpdatesState() {
        sut = makeSUT()

        sut.saveQRData("new-qr-data")

        XCTAssertEqual(mockStorage.saveCallCount, 1)
        XCTAssertTrue(sut.hasCredential)
        XCTAssertEqual(sut.credentialModel?.qrData, "new-qr-data")
        XCTAssertEqual(sut.credentialModel?.schoolCode, "escom")
    }

    // MARK: - deleteCredential

    func test_deleteCredential_removesFromStorageAndState() {
        let credential = makeTestCredential(schoolCode: "escom")
        mockStorage.storedCredentials["escom"] = credential
        sut = makeSUT()
        sut.loadSavedCredential()

        sut.deleteCredential()

        XCTAssertEqual(mockStorage.deleteCallCount, 1)
        XCTAssertEqual(mockStorage.lastDeletedSchoolCode, "escom")
        XCTAssertNil(sut.credentialModel)
        XCTAssertFalse(sut.hasCredential)
    }

    // MARK: - Computed properties

    func test_initials_computesFromName() {
        sut = makeSUT()
        sut.personalData = ["name": "Juan Garcia Lopez"]

        XCTAssertEqual(sut.initials, "JG")
    }

    func test_initials_whenSingleName_returnsSingleLetter() {
        sut = makeSUT()
        sut.personalData = ["name": "Juan"]

        XCTAssertEqual(sut.initials, "J")
    }

    func test_initials_whenEmpty_returnsEmpty() {
        sut = makeSUT()

        XCTAssertEqual(sut.initials, "")
    }

    func test_studentName_returnsFromPersonalData() {
        sut = makeSUT()
        sut.personalData = ["name": "Test Student"]

        XCTAssertEqual(sut.studentName, "Test Student")
    }

    func test_studentID_returnsFromPersonalData() {
        sut = makeSUT()
        sut.personalData = ["studentID": "2020630123"]

        XCTAssertEqual(sut.studentID, "2020630123")
    }

    func test_hasCredential_falseWhenNil() {
        sut = makeSUT()

        XCTAssertFalse(sut.hasCredential)
    }

    func test_hasCredential_trueAfterSave() {
        sut = makeSUT()
        sut.saveQRData("data")

        XCTAssertTrue(sut.hasCredential)
    }

    // MARK: - fetchProfilePicture

    func test_fetchProfilePicture_setsData() async {
        let imageData = Data([0x89, 0x50, 0x4E, 0x47])
        mockProfilePictureDataSource.result = .success(imageData)
        sut = makeSUT()

        await sut.fetchProfilePicture()

        XCTAssertEqual(sut.profilePicture, imageData)
        XCTAssertEqual(mockProfilePictureDataSource.fetchCallCount, 1)
    }

    func test_fetchProfilePicture_whenFails_leavesNil() async {
        mockProfilePictureDataSource.result = .failure(URLError(.badURL))
        sut = makeSUT()

        await sut.fetchProfilePicture()

        XCTAssertNil(sut.profilePicture)
    }

    // MARK: - schoolCode usage

    func test_saveQRData_usesCurrentSchoolCode() {
        sut = makeSUT(schoolCode: "cecyt9")

        sut.saveQRData("qr-data")

        XCTAssertEqual(sut.credentialModel?.schoolCode, "cecyt9")
        XCTAssertNotNil(mockStorage.storedCredentials["cecyt9"])
    }

    func test_deleteCredential_usesCurrentSchoolCode() {
        sut = makeSUT(schoolCode: "upiicsa")
        sut.saveQRData("qr-data")

        sut.deleteCredential()

        XCTAssertEqual(mockStorage.lastDeletedSchoolCode, "upiicsa")
    }

    // MARK: - Helpers

    private func makeTestCredential(schoolCode: String) -> CredentialModel {
        CredentialModel(
            qrData: "test-qr-data",
            scannedDate: Date(),
            schoolCode: schoolCode
        )
    }
}
