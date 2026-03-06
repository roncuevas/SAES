import XCTest
@testable import SAES

@MainActor
final class DeepLinkHandlerTests: XCTestCase {

    // MARK: - classify: Tab destinations

    func test_classify_home_returnsTab() {
        let url = URL(string: "saes://home")!
        let action = DeepLinkHandler.classify(url)
        if case .tab(let tab) = action {
            XCTAssertEqual(tab, .home)
        } else {
            XCTFail("Expected .tab(.home), got \(action)")
        }
    }

    func test_classify_personalData_returnsTab() {
        let url = URL(string: "saes://personalData")!
        let action = DeepLinkHandler.classify(url)
        if case .tab(let tab) = action {
            XCTAssertEqual(tab, .personalData)
        } else {
            XCTFail("Expected .tab(.personalData), got \(action)")
        }
    }

    func test_classify_schedules_returnsTab() {
        let url = URL(string: "saes://schedules")!
        if case .tab(let tab) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(tab, .schedules)
        } else {
            XCTFail("Expected .tab(.schedules)")
        }
    }

    func test_classify_grades_returnsTab() {
        let url = URL(string: "saes://grades")!
        if case .tab(let tab) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(tab, .grades)
        } else {
            XCTFail("Expected .tab(.grades)")
        }
    }

    func test_classify_kardex_returnsTab() {
        let url = URL(string: "saes://kardex")!
        if case .tab(let tab) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(tab, .kardex)
        } else {
            XCTFail("Expected .tab(.kardex)")
        }
    }

    // MARK: - classify: Router destinations

    func test_classify_news_returnsDestination() {
        let url = URL(string: "saes://news")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .news)
        } else {
            XCTFail("Expected .destination(.news)")
        }
    }

    func test_classify_scholarships_returnsDestination() {
        let url = URL(string: "saes://scholarships")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .scholarships)
        } else {
            XCTFail("Expected .destination(.scholarships)")
        }
    }

    func test_classify_settings_returnsDestination() {
        let url = URL(string: "saes://settings")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .settings)
        } else {
            XCTFail("Expected .destination(.settings)")
        }
    }

    func test_classify_credential_returnsDestination() {
        let url = URL(string: "saes://credential")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .credential)
        } else {
            XCTFail("Expected .destination(.credential)")
        }
    }

    func test_classify_ipnSchedule_returnsDestination() {
        let url = URL(string: "saes://ipnSchedule")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .ipnSchedule)
        } else {
            XCTFail("Expected .destination(.ipnSchedule)")
        }
    }

    func test_classify_announcements_returnsDestination() {
        let url = URL(string: "saes://announcements")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .announcements)
        } else {
            XCTFail("Expected .destination(.announcements)")
        }
    }

    func test_classify_offlineMode_returnsDestination() {
        let url = URL(string: "saes://offlineMode")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .offlineMode)
        } else {
            XCTFail("Expected .destination(.offlineMode)")
        }
    }

    func test_classify_scheduleAvailability_returnsDestination() {
        let url = URL(string: "saes://scheduleAvailability")!
        if case .destination(let dest) = DeepLinkHandler.classify(url) {
            XCTAssertEqual(dest, .scheduleAvailability)
        } else {
            XCTFail("Expected .destination(.scheduleAvailability)")
        }
    }

    // MARK: - classify: Invalid URLs

    func test_classify_invalidHost_returnsNone() {
        let url = URL(string: "saes://invalid")!
        if case .none = DeepLinkHandler.classify(url) {
            // Expected
        } else {
            XCTFail("Expected .none for invalid host")
        }
    }

    func test_classify_wrongScheme_returnsNone() {
        let url = URL(string: "https://news")!
        if case .none = DeepLinkHandler.classify(url) {
            // Expected
        } else {
            XCTFail("Expected .none for wrong scheme")
        }
    }

    // MARK: - DeepLinkManager

    func test_manager_enqueueAndConsume() {
        let manager = DeepLinkManager.shared
        let url = URL(string: "saes://news")!

        manager.enqueue(url)
        XCTAssertEqual(manager.pendingURL, url)

        let consumed = manager.consume()
        XCTAssertEqual(consumed, url)
        XCTAssertNil(manager.pendingURL)
    }

    func test_manager_consumeWhenEmpty_returnsNil() {
        let manager = DeepLinkManager.shared
        manager.consume()
        XCTAssertNil(manager.consume())
    }
}
