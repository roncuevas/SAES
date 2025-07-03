import Foundation

struct EvaluationTeachersDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        let url = URL(string: URLConstants.evalTeachers.value)
        guard let url else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }
}
