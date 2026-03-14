import Foundation

@MainActor
final class ScholarshipsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var scholarships: [IPNScholarship]
    @Published var searchText: String
    private let manager: ScholarshipManager
    private let logger = Logger(logLevel: .info)

    var filteredScholarships: [IPNScholarship] {
        guard !searchText.isEmpty else { return scholarships }
        return scholarships.filter {
            $0.titulo.localizedStandardContains(searchText) ||
            $0.descripcion.localizedStandardContains(searchText)
        }
    }

    init(manager: ScholarshipManager = .shared) {
        self.loadingState = .idle
        self.scholarships = []
        self.searchText = ""
        self.manager = manager
    }

    func getScholarships() async {
        logger.log(level: .info, message: "Starting fetch, current state: \(loadingState)", source: "ScholarshipsViewModel")
        setLoadingState(.loading)
        do {
            try await PerformanceManager.shared.measure(name: "fetch_scholarships") {
                try await manager.fetch()
            }
            scholarships = manager.scholarships
            logger.log(level: .info, message: "Fetched \(scholarships.count) scholarships", source: "ScholarshipsViewModel")
            setLoadingState(scholarships.isEmpty ? .empty : .loaded)
            logger.log(level: .info, message: "State set to: \(loadingState)", source: "ScholarshipsViewModel")
        } catch {
            logger.log(level: .error, message: "Error: \(error)", source: "ScholarshipsViewModel")
            if let urlError = error as? URLError,
               [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(urlError.code) {
                setLoadingState(.noNetwork)
            } else {
                setLoadingState(.error)
            }
        }
    }
}
