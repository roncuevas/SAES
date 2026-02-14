import Foundation

protocol NewsFetcher: Sendable {
    func fetchNews() async throws -> IPNStatementModel
}
