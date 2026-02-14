import Foundation
@testable import SAES

final class MockNetworkClient: NetworkClient, @unchecked Sendable {
    var mockData: Data?
    var mockError: Error?

    func sendRequest<T: Codable>(url: String,
                                 method: String,
                                 headers: [String: String]?,
                                 type: T.Type) async throws -> T {
        if let error = mockError {
            throw error
        }
        guard let data = mockData else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(type, from: data)
    }
}
