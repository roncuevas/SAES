import XCTest
@testable import SAES

final class AppDestinationTests: XCTestCase {

    // MARK: - Hashable conformance

    func test_sameCasesAreEqual() {
        XCTAssertEqual(AppDestination.logged, AppDestination.logged)
        XCTAssertEqual(AppDestination.login, AppDestination.login)
        XCTAssertEqual(AppDestination.settings, AppDestination.settings)
    }

    func test_differentCasesAreNotEqual() {
        XCTAssertNotEqual(AppDestination.logged, AppDestination.login)
        XCTAssertNotEqual(AppDestination.news, AppDestination.settings)
        XCTAssertNotEqual(AppDestination.mainView, AppDestination.splashScreenView)
    }

    // MARK: - All cases covered

    func test_allCasesExist() {
        let allCases: [AppDestination] = [
            .splashScreenView,
            .mainView,
            .setup,
            .login,
            .logged,
            .news,
            .ipnSchedule,
            .scheduleAvailability,
            .credential,
            .settings,
        ]
        XCTAssertEqual(allCases.count, 10)
    }

    // MARK: - Hashable in collections

    func test_canBeUsedAsSetElement() {
        let destinations: Set<AppDestination> = [.logged, .login, .logged]
        XCTAssertEqual(destinations.count, 2)
    }

    func test_canBeUsedAsDictionaryKey() {
        let map: [AppDestination: String] = [
            .logged: "Logged",
            .login: "Login",
        ]
        XCTAssertEqual(map[.logged], "Logged")
        XCTAssertEqual(map[.login], "Login")
    }
}
