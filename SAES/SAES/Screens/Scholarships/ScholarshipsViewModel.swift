import Foundation

@MainActor
final class ScholarshipsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var scholarships: [IPNScholarship]
    @Published var searchText: String
    private let manager: ScholarshipManager

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
        setLoadingState(.loading)
        await manager.fetch()
        scholarships = manager.scholarships
        if scholarships.isEmpty {
            setLoadingState(.empty)
        } else {
            setLoadingState(.loaded)
        }
    }
}
