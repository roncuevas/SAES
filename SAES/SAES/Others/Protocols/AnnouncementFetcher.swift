import Foundation

protocol AnnouncementFetcher: Sendable {
    func fetchAnnouncements(limit: Int, includeExpired: Bool) async throws -> IPNAnnouncementResponse
}
