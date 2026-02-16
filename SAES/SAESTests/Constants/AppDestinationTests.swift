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

    // MARK: - DestinationType conformance

    func test_fromPath_returnsCorrectDestination() {
        XCTAssertEqual(AppDestination.from(path: "splash", fullPath: ["splash"], parameters: [:]), .splashScreenView)
        XCTAssertEqual(AppDestination.from(path: "main", fullPath: ["main"], parameters: [:]), .mainView)
        XCTAssertEqual(AppDestination.from(path: "setup", fullPath: ["setup"], parameters: [:]), .setup)
        XCTAssertEqual(AppDestination.from(path: "login", fullPath: ["login"], parameters: [:]), .login)
        XCTAssertEqual(AppDestination.from(path: "logged", fullPath: ["logged"], parameters: [:]), .logged)
        XCTAssertEqual(AppDestination.from(path: "news", fullPath: ["news"], parameters: [:]), .news)
        XCTAssertEqual(AppDestination.from(path: "ipnSchedule", fullPath: ["ipnSchedule"], parameters: [:]), .ipnSchedule)
        XCTAssertEqual(AppDestination.from(path: "scheduleAvailability", fullPath: ["scheduleAvailability"], parameters: [:]), .scheduleAvailability)
        XCTAssertEqual(AppDestination.from(path: "credential", fullPath: ["credential"], parameters: [:]), .credential)
        XCTAssertEqual(AppDestination.from(path: "settings", fullPath: ["settings"], parameters: [:]), .settings)
    }

    func test_fromPath_returnsNilForUnknownPath() {
        XCTAssertNil(AppDestination.from(path: "unknown", fullPath: ["unknown"], parameters: [:]))
        XCTAssertNil(AppDestination.from(path: "", fullPath: [""], parameters: [:]))
        XCTAssertNil(AppDestination.from(path: "home", fullPath: ["home"], parameters: [:]))
    }
}
