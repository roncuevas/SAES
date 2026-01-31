import Foundation

extension NewsFetcher {
    func fetchNews() async -> IPNStatementModel {
        let statementsURL = "https://api.roncuevas.com/ipn/statements"
        do {
            return try await NetworkManager.shared.sendRequest(url: statementsURL,
                                                               type: IPNStatementModel.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "NewsFetcher")
        }
        return []
    }
}
