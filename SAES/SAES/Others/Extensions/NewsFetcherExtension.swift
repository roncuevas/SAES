import Foundation

extension NewsFetcher {
    func fetchNews() async -> IPNStatementModel {
        do {
            return try await NetworkManager.shared.sendRequest(url: URLConstants.ipnStatements,
                                                               type: IPNStatementModel.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "NewsFetcher")
        }
        return []
    }
}
