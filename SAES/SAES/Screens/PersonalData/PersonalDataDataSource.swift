import Foundation

struct PersonalDataDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        guard let url = URL(string: URLConstants.personalData.value)
        else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
