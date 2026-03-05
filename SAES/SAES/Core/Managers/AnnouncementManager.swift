import Foundation

struct DefaultAnnouncementFetcher: AnnouncementFetcher {
    func fetchAnnouncements() async throws -> IPNAnnouncementResponse {
        try await NetworkManager.shared.sendRequest(
            url: URLConstants.ipnAnnouncements,
            type: IPNAnnouncementResponse.self
        )
    }
}

@MainActor
final class AnnouncementManager: ObservableObject {
    static let shared = AnnouncementManager()

    @Published private(set) var response: IPNAnnouncementResponse?
    @Published private(set) var announcements: [IPNAnnouncement] = []
    private let fetcher: any AnnouncementFetcher
    private let logger = Logger(logLevel: .info)

    init(fetcher: any AnnouncementFetcher = DefaultAnnouncementFetcher()) {
        self.fetcher = fetcher
    }

    func fetch() async throws {
        let fetcher = self.fetcher
        let result = try await fetcher.fetchAnnouncements()
        response = result
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

    // MARK: - Filtering

    func announcements(for schoolCode: String) -> [IPNAnnouncement] {
        announcements.filter { announcement in
            guard let escuelas = announcement.escuelas else { return true }
            return escuelas.contains(schoolCode)
        }
    }
}
