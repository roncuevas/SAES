import Foundation
@preconcurrency import FirebasePerformance

protocol SAESDataSource: Sendable {
    var sessionProvider: UserSessionProvider { get }
    func fetch() async throws -> Data
    func SAESFetcher(url: URL) async throws -> Data
}

extension SAESDataSource {
    var sessionProvider: UserSessionProvider {
        UserSessionManager.shared
    }

    func SAESFetcher(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        let cookies = await sessionProvider.cookiesString()
        request.setValue(cookies, forHTTPHeaderField: AppConstants.HTTPHeaders.cookie)

        let metric = HTTPMetric(url: url, httpMethod: .get)
        metric?.start()

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                metric?.responseCode = httpResponse.statusCode
            }
            metric?.responsePayloadSize = Int64(data.count)
            metric?.stop()
            return data
        } catch {
            metric?.stop()
            throw error
        }
    }
}
