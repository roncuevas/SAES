import Foundation

enum NewsViewMode: Sendable {
    case grid
    case list
}

struct DefaultNewsFetcher: NewsFetcher {
    func fetchNews() async throws -> IPNStatementModel {
        try await NetworkManager.shared.sendRequest(
            url: URLConstants.ipnStatements,
            type: IPNStatementModel.self
        )
    }
}

@MainActor
final class NewsViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState
    @Published var news: IPNStatementModel
    @Published var searchText: String
    @Published var viewMode: NewsViewMode
    private let newsFetcher: any NewsFetcher
    private let logger: Logger

    var filteredNews: IPNStatementModel {
        guard !searchText.isEmpty else { return news }
        return news.filter {
            $0.title.localizedStandardContains(searchText)
        }
    }

    var featuredNews: IPNStatementModelElement? {
        filteredNews.first
    }

    var remainingNews: IPNStatementModel {
        Array(filteredNews.dropFirst())
    }

    init(newsFetcher: any NewsFetcher = DefaultNewsFetcher()) {
        self.loadingState = .idle
        self.news = []
        self.searchText = ""
        self.viewMode = .list
        self.newsFetcher = newsFetcher
        self.logger = Logger(logLevel: .info)
    }

    func getNews() async {
        let fetcher = self.newsFetcher
        do {
            let data = try await performLoading {
                try await fetcher.fetchNews()
            }
            self.news = data
            if data.isEmpty {
                setLoadingState(.empty)
                logger.log(level: .warning, message: "Sin noticias", source: "NewsViewModel")
            } else {
                logger.log(level: .info, message: "Noticias obtenidas: \(data.count)", source: "NewsViewModel")
            }
        } catch {
            logger.log(level: .error, message: "Error al obtener noticias: \(error.localizedDescription)", source: "NewsViewModel")
        }
    }
}
