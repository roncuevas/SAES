import Foundation

protocol SAESDataSource {
    func fetch() async throws -> Data
    func SAESFetcher(url: URL) async throws -> Data
}

extension SAESDataSource {
    func SAESFetcher(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        return try await URLSession.shared.data(for: request).0
    }

    func SAESFetcherRedirected(url: URL) async throws -> (data: Data, redirected: Bool) {
        var request = URLRequest(url: url)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        let (data, response) = try await URLSession.shared.data(for: request)
        return (data, request.url != response.url)
    }

    func SAESFetcherString(url: URL) async throws -> String? {
        var request = URLRequest(url: url)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        let (data, _) = try await URLSession.shared.data(for: request)
        return String(data: data, encoding: .utf8)
    }
}
