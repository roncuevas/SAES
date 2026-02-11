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
            personalDataSource: mockDataSource,
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

    func test_loadSavedCredential_restoresWebData() {
        let webData = makeTestWebData()
        let credential = makeTestCredential(schoolCode: "escom", webData: webData)
        mockStorage.storedCredentials["escom"] = credential
        sut = makeSUT()

        sut.loadSavedCredential()

        XCTAssertNotNil(sut.credentialWebData)
        XCTAssertEqual(sut.credentialWebData?.studentName, "JUAN PEREZ GARCIA")
        XCTAssertEqual(sut.credentialWebData?.career, "INGENIERÍA EN SISTEMAS COMPUTACIONALES")
        XCTAssertTrue(sut.credentialWebData?.isEnrolled ?? false)
    }

    // MARK: - saveQRData

    func test_saveQRData_persistsAndUpdatesState() {
        sut = makeSUT()

        sut.saveQRData("new-qr-data")

        XCTAssertEqual(mockStorage.saveCallCount, 1)
        XCTAssertTrue(sut.hasCredential)
        XCTAssertEqual(sut.credentialModel?.qrData, "new-qr-data")
        XCTAssertEqual(sut.credentialModel?.schoolCode, "escom")
        XCTAssertNil(sut.credentialModel?.webData)
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
        XCTAssertNil(sut.credentialWebData)
        XCTAssertFalse(sut.hasCredential)
    }

    // MARK: - Computed properties with web data

    func test_studentName_prefersWebData() {
        sut = makeSUT()
        sut.personalData = ["name": "From PersonalData"]
        sut.credentialWebData = makeTestWebData(name: "From Web")

        XCTAssertEqual(sut.studentName, "From Web")
    }

    func test_studentName_fallsBackToPersonalData() {
        sut = makeSUT()
        sut.personalData = ["name": "From PersonalData"]

        XCTAssertEqual(sut.studentName, "From PersonalData")
    }

    func test_studentID_prefersWebData() {
        sut = makeSUT()
        sut.personalData = ["studentID": "111"]
        sut.credentialWebData = makeTestWebData(studentID: "222")

        XCTAssertEqual(sut.studentID, "222")
    }

    func test_career_returnsFromWebData() {
        sut = makeSUT()
        sut.credentialWebData = makeTestWebData(career: "MÉDICO CIRUJANO")

        XCTAssertEqual(sut.career, "MÉDICO CIRUJANO")
    }

    func test_career_emptyWhenNoWebData() {
        sut = makeSUT()

        XCTAssertEqual(sut.career, "")
    }

    func test_schoolName_prefersWebData() {
        sut = makeSUT()
        sut.credentialWebData = makeTestWebData(school: "ESCOM")

        XCTAssertEqual(sut.schoolName, "ESCOM")
    }

    func test_isEnrolled_fromWebData() {
        sut = makeSUT()
        sut.credentialWebData = makeTestWebData(isEnrolled: true)

        XCTAssertTrue(sut.isEnrolled)
    }

    func test_isEnrolled_falseByDefault() {
        sut = makeSUT()

        XCTAssertFalse(sut.isEnrolled)
    }

    func test_validityText_emptyWhenNoWebData() {
        sut = makeSUT()

        XCTAssertEqual(sut.validityText, "")
    }

    // MARK: - Computed properties (basic)

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

    private func makeTestCredential(schoolCode: String, webData: CredentialWebData? = nil) -> CredentialModel {
        CredentialModel(
            qrData: "test-qr-data",
            scannedDate: Date(),
            schoolCode: schoolCode,
            webData: webData
        )
    }

    private func makeTestWebData(
        studentID: String = "2020630123",
        name: String = "JUAN PEREZ GARCIA",
        career: String = "INGENIERÍA EN SISTEMAS COMPUTACIONALES",
        school: String = "ESCUELA SUPERIOR DE CÓMPUTO (ESCOM)",
        isEnrolled: Bool = true,
        profilePictureBase64: String? = nil
    ) -> CredentialWebData {
        CredentialWebData(
            studentID: studentID,
            studentName: name,
            curp: "PEGJ000101HMCRRN01",
            career: career,
            school: school,
            cctCode: "09DPN0085X",
            isEnrolled: isEnrolled,
            statusText: isEnrolled ? "09DPN0085X" : "CREDENCIAL NO VIGENTE",
            profilePictureBase64: profilePictureBase64
        )
    }
}
