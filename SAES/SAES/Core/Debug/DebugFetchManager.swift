import Foundation
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseRemoteConfig

final class DebugFetchManager: @unchecked Sendable {
    static let shared = DebugFetchManager()
    private let logger = Logger(logLevel: .error)
    private let firestore = FirestoreManager(collectionName: "debugx")
    private init() {}

    func executeIfEnabled() async {
        let enabled = RemoteConfig.remoteConfig()
            .configValue(forKey: AppConstants.RemoteConfigKeys.debugxScrapping)
            .boolValue
        guard enabled else { return }

        do {
            let urls = try await fetchURLList()
            await fetchAndStoreAll(urls)
        } catch {
            logger.log(level: .error, message: "DebugFetch failed: \(error)", source: "DebugFetchManager")
        }
    }

    private func fetchURLList() async throws -> [String] {
        guard let url = URL(string: URLConstants.scrapperDebug) else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(DebugFetchResponse.self, from: data)
        guard response.success else { return [] }
        return response.urls
    }

    private func fetchAndStoreAll(_ urls: [String]) async {
        for urlString in urls {
            await fetchAndStore(urlString: urlString)
        }
    }

    private func fetchAndStore(urlString: String) async {
        let documentID = urlString.sha256
        do {
            guard let url = URL(string: urlString) else {
                try await firestore.saveDocument(id: documentID, data: [
                    "url": urlString,
                    "response": "",
                    "timestamp": firestore.timestamp
                ])
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let html = String(data: data, encoding: .utf8) ?? ""
            try await firestore.saveDocument(id: documentID, data: [
                "url": urlString,
                "response": html,
                "timestamp": firestore.timestamp
            ])
        } catch {
            logger.log(level: .error, message: "DebugFetch store failed for \(urlString): \(error)", source: "DebugFetchManager")
        }
    }
}
