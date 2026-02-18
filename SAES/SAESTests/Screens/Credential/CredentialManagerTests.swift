import XCTest
@testable import SAES

final class CredentialManagerTests: XCTestCase {
    private var mockStorage: MockCredentialStorageClient!
    private var mockCacheManager: MockCredentialCacheClient!
    private var sut: CredentialManager!

    override func setUp() {
        super.setUp()
        mockStorage = MockCredentialStorageClient()
        mockCacheManager = MockCredentialCacheClient()
        sut = CredentialManager(storage: mockStorage, cacheManager: mockCacheManager)
    }

    override func tearDown() {
        mockStorage = nil
        mockCacheManager = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - load

    func test_load_whenNoCredential_returnsNils() {
        let (model, webData) = sut.load(for: "escom")

        XCTAssertNil(model)
        XCTAssertNil(webData)
    }

    func test_load_prefersCacheOverEmbedded() {
        let embeddedWebData = makeTestWebData(name: "EMBEDDED")
        let cachedWebData = makeTestWebData(name: "CACHED")
        mockStorage.storedCredentials["escom"] = makeTestCredential(schoolCode: "escom", webData: embeddedWebData)
        mockCacheManager.cachedData["escom"] = cachedWebData

        let (model, webData) = sut.load(for: "escom")

        XCTAssertNotNil(model)
        XCTAssertEqual(webData?.studentName, "CACHED")
    }

    func test_load_migratesEmbeddedToCache() {
        let webData = makeTestWebData(name: "TO MIGRATE")
        mockStorage.storedCredentials["escom"] = makeTestCredential(schoolCode: "escom", webData: webData)

        let (model, returnedWebData) = sut.load(for: "escom")

        XCTAssertNotNil(model)
        XCTAssertEqual(returnedWebData?.studentName, "TO MIGRATE")
        XCTAssertEqual(mockCacheManager.saveCallCount, 1)
        XCTAssertEqual(mockCacheManager.cachedData["escom"]?.studentName, "TO MIGRATE")
    }

    // MARK: - save

    func test_save_createsModelWithCorrectSchoolCode() {
        let model = sut.save(qrData: "test-qr", schoolCode: "escatep")

        XCTAssertEqual(model.qrData, "test-qr")
        XCTAssertEqual(model.schoolCode, "escatep")
        XCTAssertNil(model.webData)
        XCTAssertEqual(mockStorage.saveCallCount, 1)
        XCTAssertNotNil(mockStorage.storedCredentials["escatep"])
    }

    // MARK: - persist

    func test_persist_updatesModelWithWebData() {
        let model = sut.save(qrData: "test-qr", schoolCode: "escom")
        let webData = makeTestWebData(name: "PERSISTED")

        let updated = sut.persist(model: model, webData: webData, existingProfilePicture: nil)

        XCTAssertEqual(updated.webData?.studentName, "PERSISTED")
        XCTAssertEqual(updated.schoolCode, "escom")
        XCTAssertEqual(mockCacheManager.saveCallCount, 1)
        XCTAssertEqual(mockStorage.saveCallCount, 2)
    }

    func test_persist_preservesExistingProfilePicture() {
        let model = sut.save(qrData: "test-qr", schoolCode: "escom")
        let webData = makeTestWebData(profilePictureBase64: nil)

        let updated = sut.persist(model: model, webData: webData, existingProfilePicture: "existing-base64")

        XCTAssertEqual(updated.webData?.profilePictureBase64, "existing-base64")
    }

    func test_persist_usesNewProfilePictureWhenProvided() {
        let model = sut.save(qrData: "test-qr", schoolCode: "escom")
        let webData = makeTestWebData(profilePictureBase64: "new-base64")

        let updated = sut.persist(model: model, webData: webData, existingProfilePicture: "old-base64")

        XCTAssertEqual(updated.webData?.profilePictureBase64, "new-base64")
    }

    // MARK: - delete

    func test_delete_removesBothStorageAndCache() {
        _ = sut.save(qrData: "test-qr", schoolCode: "escom")
        mockCacheManager.cachedData["escom"] = makeTestWebData()

        sut.delete(for: "escom")

        XCTAssertEqual(mockStorage.deleteCallCount, 1)
        XCTAssertEqual(mockStorage.lastDeletedSchoolCode, "escom")
        XCTAssertEqual(mockCacheManager.deleteCallCount, 1)
        XCTAssertEqual(mockCacheManager.lastDeletedSchoolCode, "escom")
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
        name: String = "JUAN PEREZ GARCIA",
        profilePictureBase64: String? = nil
    ) -> CredentialWebData {
        CredentialWebData(
            studentID: "2020630123",
            studentName: name,
            curp: "PEGJ000101HMCRRN01",
            career: "INGENIERÍA EN SISTEMAS COMPUTACIONALES",
            school: "ESCUELA SUPERIOR DE CÓMPUTO (ESCOM)",
            cctCode: "09DPN0085X",
            isEnrolled: true,
            statusText: "09DPN0085X",
            profilePictureBase64: profilePictureBase64
        )
    }
}
