import Foundation

struct UIConfiguration {
    let animationSpeed: Int
    let calendarMaxEvents: Int
    let homeMaxEvents: Int
    let homeNewsCount: Int
    let homeNewsColumns: Int
    let homeScholarshipsCount: Int
    let homeAnnouncementsCount: Int
    let reviewRequestLoginCount: Int

    static let shared = UIConfiguration(
        animationSpeed: 4,
        calendarMaxEvents: 5,
        homeMaxEvents: 3,
        homeNewsCount: 6,
        homeNewsColumns: 2,
        homeScholarshipsCount: 3,
        homeAnnouncementsCount: 3,
        reviewRequestLoginCount: 3
    )
}
