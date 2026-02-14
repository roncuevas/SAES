import XCTest
@testable import SAES

final class UserSessionManagerTests: XCTestCase {
    private var mockStorage: MockLocalStorageClient!
    private var sut: UserSessionManager!

    override func setUp() {
        super.setUp()
        mockStorage = MockLocalStorageClient()
    }

    override func tearDown() {
        mockStorage = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - currentUser Tests

    func test_currentUser_whenNoUserStored_returnsNil() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let user = await sut.currentUser()

        XCTAssertNil(user)
        XCTAssertEqual(mockStorage.loadUserCallCount, 1)
    }

    func test_currentUser_whenUserStored_returnsUser() async {
        let expectedUser = makeTestUser(schoolCode: "test")
        mockStorage.storedUsers["test"] = expectedUser
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let user = await sut.currentUser()

        XCTAssertNotNil(user)
        XCTAssertEqual(user?.studentID, expectedUser.studentID)
    }

    // MARK: - cookies Tests

    func test_cookies_whenNoUser_returnsEmptyArray() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let cookies = await sut.cookies()

        XCTAssertTrue(cookies.isEmpty)
    }

    func test_cookies_whenUserHasCookies_returnsCookies() async {
        let testCookies = [makeTestCookie(name: "session", value: "abc123")]
        let user = makeTestUser(schoolCode: "test", cookies: testCookies)
        mockStorage.storedUsers["test"] = user
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let cookies = await sut.cookies()

        XCTAssertEqual(cookies.count, 1)
        XCTAssertEqual(cookies.first?.name, "session")
        XCTAssertEqual(cookies.first?.value, "abc123")
    }

    // MARK: - cookiesString Tests

    func test_cookiesString_formatsCorrectly() async {
        let testCookies = [
            makeTestCookie(name: "session", value: "abc"),
            makeTestCookie(name: "auth", value: "xyz")
        ]
        let user = makeTestUser(schoolCode: "test", cookies: testCookies)
        mockStorage.storedUsers["test"] = user
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let cookiesString = await sut.cookiesString()

        XCTAssertEqual(cookiesString, "session=abc; auth=xyz")
    }

    func test_cookiesString_whenNoCookies_returnsEmptyString() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let cookiesString = await sut.cookiesString()

        XCTAssertEqual(cookiesString, "")
    }

    // MARK: - saveUser Tests

    func test_saveUser_persistsToStorage() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )
        let user = makeTestUser(schoolCode: "test")

        await sut.saveUser(user)

        XCTAssertEqual(mockStorage.saveUserCallCount, 1)
        XCTAssertNotNil(mockStorage.storedUsers["test"])
    }

    // MARK: - updateCookies Tests

    func test_updateCookies_updatesUserCookies() async {
        let initialUser = makeTestUser(schoolCode: "test", cookies: [])
        mockStorage.storedUsers["test"] = initialUser
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let newCookies = [makeTestCookie(name: "new", value: "cookie")]
        await sut.updateCookies(newCookies)

        let updatedUser = mockStorage.storedUsers["test"]
        XCTAssertEqual(updatedUser?.cookie.count, 1)
        XCTAssertEqual(updatedUser?.cookie.first?.name, "new")
    }

    func test_updateCookies_whenNoUser_doesNothing() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let newCookies = [makeTestCookie(name: "new", value: "cookie")]
        await sut.updateCookies(newCookies)

        XCTAssertEqual(mockStorage.saveUserCallCount, 0)
    }

    // MARK: - Dirty Checking Tests

    func test_saveUser_writesWhenDataChanged() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )
        let user1 = makeTestUser(schoolCode: "test", studentID: "111")
        let user2 = makeTestUser(schoolCode: "test", studentID: "222")

        await sut.saveUser(user1)
        await sut.saveUser(user2)

        XCTAssertEqual(mockStorage.saveUserCallCount, 2, "Should write both times when data differs")
    }

    func test_updateCookies_skipsWhenCookiesUnchanged() async {
        let cookies = [makeTestCookie(name: "session", value: "abc")]
        let user = makeTestUser(schoolCode: "test", cookies: cookies)
        mockStorage.storedUsers["test"] = user
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        await sut.updateCookies(cookies)

        XCTAssertEqual(mockStorage.saveUserCallCount, 0, "Should not write when cookies are unchanged")
    }

    func test_updateCookies_writesWhenCookiesChanged() async {
        let initialCookies = [makeTestCookie(name: "session", value: "abc")]
        let user = makeTestUser(schoolCode: "test", cookies: initialCookies)
        mockStorage.storedUsers["test"] = user
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        let newCookies = [makeTestCookie(name: "session", value: "xyz")]
        await sut.updateCookies(newCookies)

        XCTAssertEqual(mockStorage.saveUserCallCount, 1, "Should write when cookies changed")
    }

    // MARK: - invalidateCache Tests

    func test_invalidateCache_delegatesToStorage() async {
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { "test" }
        )

        await sut.invalidateCache()

        XCTAssertEqual(mockStorage.invalidateCacheCallCount, 1)
        XCTAssertEqual(mockStorage.lastInvalidatedSchoolCode, "test")
    }

    func test_invalidateCache_usesCurrentSchoolCode() async {
        nonisolated(unsafe) var schoolCode = "initial"
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { schoolCode }
        )

        await sut.invalidateCache()
        XCTAssertEqual(mockStorage.lastInvalidatedSchoolCode, "initial")

        schoolCode = "changed"
        await sut.invalidateCache()
        XCTAssertEqual(mockStorage.lastInvalidatedSchoolCode, "changed")
        XCTAssertEqual(mockStorage.invalidateCacheCallCount, 2)
    }

    // MARK: - schoolCode Tests

    func test_currentSchoolCode_returnsProviderValue() async {
        nonisolated(unsafe) var schoolCode = "initial"
        sut = UserSessionManager(
            storage: mockStorage,
            schoolCodeProvider: { schoolCode }
        )

        let initialCode = await sut.currentSchoolCode
        XCTAssertEqual(initialCode, "initial")

        schoolCode = "changed"
        let changedCode = await sut.currentSchoolCode
        XCTAssertEqual(changedCode, "changed")
    }

    // MARK: - Helpers

    private func makeTestUser(
        schoolCode: String,
        studentID: String = "2020123456",
        cookies: [LocalCookieModel] = []
    ) -> LocalUserModel {
        LocalUserModel(
            schoolCode: schoolCode,
            studentID: studentID,
            password: "encryptedPassword",
            ivValue: "ivValue",
            cookie: cookies
        )
    }

    private func makeTestCookie(name: String, value: String) -> LocalCookieModel {
        LocalCookieModel(
            domain: ".saes.ipn.mx",
            hostOnly: false,
            httpOnly: true,
            name: name,
            path: "/",
            sameSite: "lax",
            secure: true,
            session: true,
            storeId: "0",
            value: value,
            id: 1
        )
    }
}
