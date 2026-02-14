import Foundation

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
        return try await URLSession.shared.data(for: request).0
    }
}
