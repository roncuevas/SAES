import Foundation

protocol AnnouncementFetcher: Sendable {
    func fetchAnnouncements() async throws -> IPNAnnouncementResponse
}
