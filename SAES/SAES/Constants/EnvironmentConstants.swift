import Foundation

struct EnvironmentConstants {
    private static let config: UIConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(UIConfiguration.self, from: "ui_config")
    }()

    static var animationSpeed: CGFloat { CGFloat(config.animationSpeed) }

    // MARK: IPNScheduleScreen
    static var calendarMaxEvents: Int { config.calendarMaxEvents }

    // MARK: HomeScreen
    static var homeMaxEvents: Int { config.homeMaxEvents }
    static var homeNewsCount: Int { config.homeNewsCount }
    static var homeNewsColumns: Int { config.homeNewsColumns }
    static var homeScholarshipsCount: Int { config.homeScholarshipsCount }
}
