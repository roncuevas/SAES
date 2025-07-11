import Foundation

struct GradesDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        let url = URL(string: URLConstants.grades.value)
        guard let url else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
