import Foundation

@MainActor
final class AnnouncementsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var announcements: [IPNAnnouncement]
    @Published var searchText: String
    @Published var selectedType: IPNAnnouncementType?
    @Published var filterMySchool: Bool
    @Published var newestFirst: Bool
    private let manager: AnnouncementManager

    var filteredAnnouncements: [IPNAnnouncement] {
        var result = announcements

        if let selectedType {
            result = result.filter { $0.tipo == selectedType }
        }

        if filterMySchool {
            let schoolCode = UserDefaults.schoolCode
            result = result.filter { announcement in
                guard let escuelas = announcement.escuelas else { return true }
                return escuelas.contains(schoolCode)
            }
        }

        if !searchText.isEmpty {
            result = result.filter {
                $0.titulo.localizedStandardContains(searchText) ||
                $0.descripcion.localizedStandardContains(searchText)
            }
        }

        result.sort { lhs, rhs in
            newestFirst ? lhs.fecha > rhs.fecha : lhs.fecha < rhs.fecha
        }

        return result
    }

    init(manager: AnnouncementManager = .shared) {
        self.loadingState = .idle
        self.announcements = []
        self.searchText = ""
        self.selectedType = nil
        self.filterMySchool = true
        self.newestFirst = true
        self.manager = manager
    }

    func getAnnouncements() async {
        setLoadingState(.loading)
        do {
            try await manager.fetch()
            announcements = manager.announcements
            setLoadingState(announcements.isEmpty ? .empty : .loaded)
        } catch {
            if let urlError = error as? URLError,
               [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(urlError.code) {
                setLoadingState(.noNetwork)
            } else {
                setLoadingState(.error)
            }
        }
    }
}
