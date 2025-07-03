import Foundation

struct ProfilePictureDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        guard let url = URL(string: URLConstants.personalPhoto.value)
        else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
