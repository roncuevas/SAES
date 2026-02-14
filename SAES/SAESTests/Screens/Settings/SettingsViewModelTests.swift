import XCTest
@testable import SAES

@MainActor
final class SettingsViewModelTests: XCTestCase {
    private var mockLocalStorage: MockLocalStorageClient!
    private var mockCredentialStorage: MockCredentialStorageClient!
    private var mockCredentialCache: MockCredentialCacheClient!
    private var testDefaults: UserDefaults!
    nonisolated(unsafe) private var didCallOnComplete: Bool!
    private var sut: SettingsViewModel!

    private let testSuiteName = "com.saes.tests.settings"

    override func setUp() {
        super.setUp()
        mockLocalStorage = MockLocalStorageClient()
        mockCredentialStorage = MockCredentialStorageClient()
        mockCredentialCache = MockCredentialCacheClient()
        testDefaults = UserDefaults(suiteName: testSuiteName)!
        testDefaults.removePersistentDomain(forName: testSuiteName)
        didCallOnComplete = false
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testSuiteName)
        testDefaults = nil
        mockLocalStorage = nil
        mockCredentialStorage = nil
        mockCredentialCache = nil
        didCallOnComplete = nil
        sut = nil
        super.tearDown()
    }

    private func makeSUT(schoolCode: String? = nil) -> SettingsViewModel {
        if let schoolCode {
            testDefaults.set(schoolCode, forKey: AppConstants.UserDefaultsKeys.schoolCode)
        }
        return SettingsViewModel(
            localStorage: mockLocalStorage,
            credentialStorage: mockCredentialStorage,
            credentialCache: mockCredentialCache,
            userDefaults: testDefaults,
            persistentDomainName: testSuiteName
        )
    }

    // MARK: - resetConfiguration — Does NOT delete JSON files

    func test_resetConfiguration_doesNotDeleteUserSession() {
        sut = makeSUT(schoolCode: "escom")

        sut.resetConfiguration(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockLocalStorage.deleteUserCallCount, 0)
    }

    func test_resetConfiguration_doesNotDeleteCredentialStorage() {
        sut = makeSUT(schoolCode: "escom")

        sut.resetConfiguration(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockCredentialStorage.deleteCallCount, 0)
    }

    func test_resetConfiguration_doesNotDeleteCredentialCache() {
        sut = makeSUT(schoolCode: "escom")

        sut.resetConfiguration(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockCredentialCache.deleteCallCount, 0)
    }

    // MARK: - resetConfiguration — Clears UserDefaults

    func test_resetConfiguration_clearsUserDefaults() {
        sut = makeSUT(schoolCode: "escom")
        testDefaults.set(true, forKey: AppConstants.UserDefaultsKeys.isLogged)
        testDefaults.set(true, forKey: AppConstants.UserDefaultsKeys.isSetted)
        testDefaults.set("dark", forKey: AppConstants.UserDefaultsKeys.appearanceMode)

        sut.resetConfiguration(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertNil(testDefaults.string(forKey: AppConstants.UserDefaultsKeys.schoolCode))
        XCTAssertFalse(testDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isLogged))
        XCTAssertFalse(testDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isSetted))
        XCTAssertNil(testDefaults.string(forKey: AppConstants.UserDefaultsKeys.appearanceMode))
    }

    // MARK: - resetConfiguration — Clears WebViewHandler state

    func test_resetConfiguration_clearsWebViewHandlerState() {
        sut = makeSUT(schoolCode: "escom")
        let handler = WebViewHandler.shared
        handler.personalData = ["name": "Test"]

        sut.resetConfiguration(webViewHandler: handler, onComplete: { didCallOnComplete = true })

        XCTAssertTrue(handler.personalData.isEmpty)
        XCTAssertTrue(handler.grades.isEmpty)
        XCTAssertTrue(handler.schedule.isEmpty)
    }

    // MARK: - resetConfiguration — Navigation

    func test_resetConfiguration_callsOnComplete() {
        sut = makeSUT(schoolCode: "escom")

        sut.resetConfiguration(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertTrue(didCallOnComplete)
    }

    // MARK: - deleteAllData — Deletes JSON files

    func test_deleteAllData_deletesUserSession() {
        sut = makeSUT(schoolCode: "escom")

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockLocalStorage.deleteUserCallCount, 1)
    }

    func test_deleteAllData_deletesCredentialStorage() {
        sut = makeSUT(schoolCode: "escom")

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockCredentialStorage.deleteCallCount, 1)
        XCTAssertEqual(mockCredentialStorage.lastDeletedSchoolCode, "escom")
    }

    func test_deleteAllData_deletesCredentialCache() {
        sut = makeSUT(schoolCode: "escom")

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockCredentialCache.deleteCallCount, 1)
        XCTAssertEqual(mockCredentialCache.lastDeletedSchoolCode, "escom")
    }

    func test_deleteAllData_usesCorrectSchoolCode() {
        sut = makeSUT(schoolCode: "cecyt9")

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockCredentialStorage.lastDeletedSchoolCode, "cecyt9")
        XCTAssertEqual(mockCredentialCache.lastDeletedSchoolCode, "cecyt9")
    }

    // MARK: - deleteAllData — Empty school code

    func test_deleteAllData_whenNoSchoolCode_skipsStorageDeletions() {
        sut = makeSUT()

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockLocalStorage.deleteUserCallCount, 0)
        XCTAssertEqual(mockCredentialStorage.deleteCallCount, 0)
        XCTAssertEqual(mockCredentialCache.deleteCallCount, 0)
    }

    func test_deleteAllData_whenEmptySchoolCode_skipsStorageDeletions() {
        testDefaults.set("", forKey: AppConstants.UserDefaultsKeys.schoolCode)
        sut = makeSUT()

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertEqual(mockLocalStorage.deleteUserCallCount, 0)
        XCTAssertEqual(mockCredentialStorage.deleteCallCount, 0)
        XCTAssertEqual(mockCredentialCache.deleteCallCount, 0)
    }

    // MARK: - deleteAllData — Also clears config (delegates to resetConfiguration)

    func test_deleteAllData_clearsUserDefaults() {
        sut = makeSUT(schoolCode: "escom")
        testDefaults.set(true, forKey: AppConstants.UserDefaultsKeys.isSetted)

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertFalse(testDefaults.bool(forKey: AppConstants.UserDefaultsKeys.isSetted))
        XCTAssertNil(testDefaults.string(forKey: AppConstants.UserDefaultsKeys.schoolCode))
    }

    func test_deleteAllData_clearsWebViewHandlerState() {
        sut = makeSUT(schoolCode: "escom")
        let handler = WebViewHandler.shared
        handler.personalData = ["name": "Test"]

        sut.deleteAllData(webViewHandler: handler, onComplete: { didCallOnComplete = true })

        XCTAssertTrue(handler.personalData.isEmpty)
    }

    func test_deleteAllData_callsOnComplete() {
        sut = makeSUT(schoolCode: "escom")

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertTrue(didCallOnComplete)
    }

    func test_deleteAllData_noSchoolCode_stillClearsDefaultsAndCallsOnComplete() {
        sut = makeSUT()
        testDefaults.set("dark", forKey: AppConstants.UserDefaultsKeys.appearanceMode)

        sut.deleteAllData(webViewHandler: WebViewHandler.shared, onComplete: { didCallOnComplete = true })

        XCTAssertNil(testDefaults.string(forKey: AppConstants.UserDefaultsKeys.appearanceMode))
        XCTAssertTrue(didCallOnComplete)
    }
}
