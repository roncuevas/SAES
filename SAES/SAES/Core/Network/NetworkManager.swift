import Foundation

final class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    
    private init() {}
    
    func sendRequest<T: Codable>(url: String,
                                 method: String = "get",
                                 headers: [String: String]? = nil,
                                 type: T.Type) async throws -> T {
        guard let url = URL(string: url) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.allHTTPHeaderFields = headers
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoded = try JSONDecoder().decode(type.self, from: data)
        return decoded
    }
}
