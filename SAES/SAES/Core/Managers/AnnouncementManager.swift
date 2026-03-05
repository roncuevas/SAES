import Foundation

struct DefaultAnnouncementFetcher: AnnouncementFetcher {
    func fetchAnnouncements(limit: Int, includeExpired: Bool) async throws -> IPNAnnouncementResponse {
        var url = URLConstants.ipnAnnouncements + "?limit=\(limit)"
        if includeExpired {
            url += "&includeExpired=true"
        }
        return try await NetworkManager.shared.sendRequest(
            url: url,
            type: IPNAnnouncementResponse.self
        )
    }
}

@MainActor
final class AnnouncementManager: ObservableObject {
    static let shared = AnnouncementManager()

    @Published private(set) var announcements: [IPNAnnouncement] = []
    private let fetcher: any AnnouncementFetcher
    private let logger = Logger(logLevel: .info)

    init(fetcher: any AnnouncementFetcher = DefaultAnnouncementFetcher()) {
        self.fetcher = fetcher
    }

    func fetch(limit: Int = 20, includeExpired: Bool = false) async throws {
        let fetcher = self.fetcher
        let result = try await fetcher.fetchAnnouncements(limit: limit, includeExpired: includeExpired)
        announcements = Self.sorted(result.data.anuncios)
        logger.log(level: .info, message: "Anuncios obtenidos: \(announcements.count)", source: "AnnouncementManager")
    }

    // MARK: - Sorting

    static func sorted(_ announcements: [IPNAnnouncement]) -> [IPNAnnouncement] {
        announcements.sorted { lhs, rhs in
            if lhs.importancia != rhs.importancia {
                return lhs.importancia > rhs.importancia
            }
            if lhs.tipo.sortPriority != rhs.tipo.sortPriority {
                return lhs.tipo.sortPriority < rhs.tipo.sortPriority
            }
            return lhs.fecha > rhs.fecha
        }
    }
}
