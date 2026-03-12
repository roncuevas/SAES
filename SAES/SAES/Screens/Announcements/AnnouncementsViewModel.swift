import Foundation

@MainActor
final class AnnouncementsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var announcements: [IPNAnnouncement]
    @Published var searchText: String
    @Published var selectedType: IPNAnnouncementType?
    @Published var selectedSchool: String?
    @Published var showExpired: Bool
    @Published var newestFirst: Bool
    private let manager: AnnouncementManager

    var availableSchools: [String] {
        let allSchools = announcements.compactMap(\.escuelas).flatMap { $0 }
        return Array(Set(allSchools)).sorted()
    }

    var filteredAnnouncements: [IPNAnnouncement] {
        var result = announcements

        if !showExpired {
            result = result.filter { !$0.isExpired }
        }

        if let selectedType {
            result = result.filter { $0.tipo == selectedType }
        }

        if let selectedSchool {
            result = result.filter { announcement in
                guard let escuelas = announcement.escuelas, !escuelas.isEmpty else { return false }
                return escuelas.contains(selectedSchool)
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
        self.selectedSchool = nil
        self.showExpired = false
        self.newestFirst = true
        self.manager = manager
    }

    func getAnnouncements() async {
        setLoadingState(.loading)
        do {
            try await PerformanceManager.shared.measure(name: "fetch_announcements") {
                try await manager.fetch(limit: 100, includeExpired: true)
            }
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
