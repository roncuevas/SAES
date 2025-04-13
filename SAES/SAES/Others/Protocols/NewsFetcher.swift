import Foundation

protocol NewsFetcher {
    func fetchNews() async throws -> IPNStatementModel
}
