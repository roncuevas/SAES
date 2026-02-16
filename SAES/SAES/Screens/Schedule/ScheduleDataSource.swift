import Foundation

struct ScheduleDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        let url = URL(string: URLConstants.schedule.value)
        guard let url else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
