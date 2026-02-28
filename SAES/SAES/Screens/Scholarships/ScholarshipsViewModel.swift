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
final class ScholarshipsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var scholarships: [IPNScholarship]
    @Published var searchText: String
    private let fetcher: any ScholarshipFetcher
    private let logger: Logger

    var filteredScholarships: [IPNScholarship] {
        guard !searchText.isEmpty else { return scholarships }
        return scholarships.filter {
            $0.titulo.localizedStandardContains(searchText) ||
            $0.descripcion.localizedStandardContains(searchText)
        }
    }

    init(fetcher: any ScholarshipFetcher = DefaultScholarshipFetcher()) {
        self.loadingState = .idle
        self.scholarships = []
        self.searchText = ""
        self.fetcher = fetcher
        self.logger = Logger(logLevel: .info)
    }

    func getScholarships() async {
        let fetcher = self.fetcher
        do {
            let response = try await performLoading {
                try await fetcher.fetchScholarships()
            }
            self.scholarships = response.data.becas
            if response.data.becas.isEmpty {
                setLoadingState(.empty)
                logger.log(level: .warning, message: "Sin becas", source: "ScholarshipsViewModel")
            } else {
                logger.log(level: .info, message: "Becas obtenidas: \(response.data.becas.count)", source: "ScholarshipsViewModel")
            }
        } catch {
            logger.log(level: .error, message: "Error al obtener becas: \(error.localizedDescription)", source: "ScholarshipsViewModel")
        }
    }
}
