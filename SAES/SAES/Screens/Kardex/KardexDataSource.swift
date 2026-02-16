import Foundation

struct KardexDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        let url = URL(string: URLConstants.kardex.value)
        guard let url else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
