import Foundation

protocol NetworkClient {
    func sendRequest<T: Codable>(url: String,
                                 method: String,
                                 headers: [String: String]?,
                                 type: T.Type) async throws -> T
}

extension NetworkClient {
    func sendRequest<T: Codable>(url: String,
                                 method: String = "get",
                                 headers: [String: String]? = nil,
                                 type: T.Type) async throws -> T {
        try await sendRequest(url: url, method: method, headers: headers, type: type)
    }
}
