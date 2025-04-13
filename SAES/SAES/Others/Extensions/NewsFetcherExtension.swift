import Foundation

extension NewsFetcher {
    func fetchNews() async -> IPNStatementModel {
        let statementsURL = "https://api.roncuevas.com/ipn/statements"
        do {
            return try await NetworkManager.shared.sendRequest(url: statementsURL,
                                                               type: IPNStatementModel.self)
        } catch {
            print(error)
        }
        return []
    }
}
