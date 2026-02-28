import Foundation

struct DefaultScholarshipFetcher: ScholarshipFetcher {
    func fetchScholarships() async throws -> IPNScholarshipResponse {
        try await NetworkManager.shared.sendRequest(
            url: URLConstants.ipnScholarships,
            type: IPNScholarshipResponse.self
        )
    }
}

@MainActor
final class ScholarshipManager: ObservableObject {
    static let shared = ScholarshipManager()

    @Published private(set) var response: IPNScholarshipResponse?
    @Published private(set) var scholarships: [IPNScholarship] = []
    private let fetcher: any ScholarshipFetcher
    private let logger = Logger(logLevel: .info)

    init(fetcher: any ScholarshipFetcher = DefaultScholarshipFetcher()) {
        self.fetcher = fetcher
    }

    func fetch() async {
        let fetcher = self.fetcher
        do {
            let result = try await fetcher.fetchScholarships()
            response = result
            scholarships = Self.sorted(result.data.becas)
            logger.log(level: .info, message: "Becas obtenidas: \(scholarships.count)", source: "ScholarshipManager")
        } catch {
            logger.log(level: .error, message: "Error al obtener becas: \(error.localizedDescription)", source: "ScholarshipManager")
        }
    }

    // MARK: - Sorting

    /// Sorts scholarships by importance:
    /// 1. Open (abierta/registro_abierto) — most urgent, may close soon
    /// 2. Upcoming (por_abrir/proximamente) — coming soon
    /// 3. Closed (cerrada) — least relevant
    /// Within each group, earlier dates come first.
    static func sorted(_ scholarships: [IPNScholarship]) -> [IPNScholarship] {
        scholarships.sorted { lhs, rhs in
            if lhs.status.sortPriority != rhs.status.sortPriority {
                return lhs.status.sortPriority < rhs.status.sortPriority
            }
            guard let fechaLhs = lhs.fecha, let fechaRhs = rhs.fecha else {
                return lhs.fecha != nil
            }
            return fechaLhs < fechaRhs
        }
    }
}
