import XCTest
@testable import SAES

@MainActor
final class AppRouterTests: XCTestCase {

    // MARK: - Initial state

    func test_initialState_hasEmptyPath() {
        let router = AppRouter()
        XCTAssertTrue(router.path.isEmpty)
    }

    func test_initialState_hasNilSheet() {
        let router = AppRouter()
        XCTAssertNil(router.presentedSheet)
    }

    // MARK: - navigateTo

    func test_navigateTo_appendsDestination() {
        let router = AppRouter()
        router.navigateTo(.logged)
        XCTAssertEqual(router.path, [.logged])
    }

    func test_navigateTo_appendsMultipleDestinations() {
        let router = AppRouter()
        router.navigateTo(.login)
        router.navigateTo(.logged)
        router.navigateTo(.settings)
        XCTAssertEqual(router.path, [.login, .logged, .settings])
    }

    // MARK: - popNavigation

    func test_popNavigation_removesLastDestination() {
        let router = AppRouter()
        router.navigateTo(.login)
        router.navigateTo(.logged)
        router.popNavigation()
        XCTAssertEqual(router.path, [.login])
    }

    func test_popNavigation_onEmptyPath_doesNotCrash() {
        let router = AppRouter()
        router.popNavigation()
        XCTAssertTrue(router.path.isEmpty)
    }

    // MARK: - popToRoot

    func test_popToRoot_clearsPath() {
        let router = AppRouter()
        router.navigateTo(.login)
        router.navigateTo(.logged)
        router.navigateTo(.settings)
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
    }

    // MARK: - Sheets

    func test_presentSheet_setsSheet() {
        let router = AppRouter()
        router.presentSheet(.debugWebView)
        XCTAssertEqual(router.presentedSheet, .debugWebView)
    }

    func test_dismissSheet_clearsSheet() {
        let router = AppRouter()
        router.presentSheet(.debugWebView)
        router.dismissSheet()
        XCTAssertNil(router.presentedSheet)
    }
}
