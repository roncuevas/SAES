import Foundation

struct EnvironmentConstants {
    private static let config = UIConfiguration.shared

    static var animationSpeed: CGFloat { CGFloat(config.animationSpeed) }

    // MARK: IPNScheduleScreen
    static var calendarMaxEvents: Int { config.calendarMaxEvents }

    // MARK: HomeScreen
    static var homeMaxEvents: Int { config.homeMaxEvents }
    static var homeNewsCount: Int { config.homeNewsCount }
    static var homeNewsColumns: Int { config.homeNewsColumns }
    static var homeScholarshipsCount: Int { config.homeScholarshipsCount }
    static var homeAnnouncementsCount: Int { config.homeAnnouncementsCount }
}
