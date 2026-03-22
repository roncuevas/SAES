import Foundation
@preconcurrency import FirebasePerformance

final class NetworkManager: NetworkClient, Sendable {
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

        let httpMethod: HTTPMethod = method.lowercased() == "post" ? .post : .get
        let metric = HTTPMetric(url: url, httpMethod: httpMethod)
        metric?.start()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                metric?.responseCode = httpResponse.statusCode
            }
            metric?.responsePayloadSize = data.count
            metric?.stop()
            let decoded = try JSONDecoder().decode(type.self, from: data)
            return decoded
        } catch {
            metric?.stop()
            throw error
        }
    }
}
