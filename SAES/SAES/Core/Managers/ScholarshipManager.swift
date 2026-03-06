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

    func fetch() async throws {
        let fetcher = self.fetcher
        let result = try await fetcher.fetchScholarships()
        response = result
        scholarships = Self.sorted(result.data.becas)
        logger.log(level: .info, message: "Becas obtenidas: \(scholarships.count)", source: "ScholarshipManager")
    }

    // MARK: - Sorting

    /// Sorts scholarships by:
    /// 1. Priority (1 = highest, 10 = lowest; nil sorted last)
    /// 2. Status: open → upcoming → closed
    /// 3. Date ascending within same priority and status
    static func sorted(_ scholarships: [IPNScholarship]) -> [IPNScholarship] {
        scholarships.sorted { lhs, rhs in
            let lhsPriority = lhs.prioridad ?? Int.max
            let rhsPriority = rhs.prioridad ?? Int.max
            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }
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
