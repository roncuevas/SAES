import Foundation

struct SchedulePDFDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        let url = URL(string: URLConstants.schedulePDF.value)
        guard let url else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
