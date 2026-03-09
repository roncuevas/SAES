import Foundation
import SwiftSoup
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseRemoteConfig

final class DebugFetchManager: @unchecked Sendable {
    static let shared = DebugFetchManager()
    private let logger = Logger(logLevel: .debug)
    private let firestore = FirestoreManager(collectionName: "debugx")
    private init() {}

    func executeIfEnabled() async {
        logger.log(level: .debug, message: "DebugFetch: checking remote config", source: "DebugFetchManager")
        let remoteConfig = RemoteConfig.remoteConfig()
        let enabled = remoteConfig
            .configValue(forKey: AppConstants.RemoteConfigKeys.debugxScrapping)
            .boolValue
        logger.log(level: .debug, message: "DebugFetch: enabled=\(enabled)", source: "DebugFetchManager")
        guard enabled else { return }

        let limit = remoteConfig
            .configValue(forKey: AppConstants.RemoteConfigKeys.debugxLimit)
            .numberValue.intValue
        logger.log(level: .debug, message: "DebugFetch: limit=\(limit)", source: "DebugFetchManager")
        guard limit > 0 else { return }

        do {
            let entries = try await fetchURLList(limit: limit)
            logger.log(level: .debug, message: "DebugFetch: fetched \(entries.count) URLs", source: "DebugFetchManager")
            await fetchAndStoreAll(entries)
            logger.log(level: .debug, message: "DebugFetch: completed", source: "DebugFetchManager")
        } catch {
            logger.log(level: .error, message: "DebugFetch failed: \(error)", source: "DebugFetchManager")
        }
    }

    private func fetchURLList(limit: Int) async throws -> [DebugFetchURL] {
        guard let url = URL(string: URLConstants.scrapperDebug + "?limit=\(limit)") else {
            throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let rawJSON = String(data: data, encoding: .utf8) ?? ""
        logger.log(level: .debug, message: "DebugFetch: raw response: \(rawJSON.prefix(500))", source: "DebugFetchManager")
        let response = try JSONDecoder().decode(DebugFetchResponse.self, from: data)
        guard response.success else { return [] }
        return response.urls
    }

    private func fetchAndStoreAll(_ entries: [DebugFetchURL]) async {
        for entry in entries {
            await fetchAndStore(entry: entry)
        }
    }

    private func fetchAndStore(entry: DebugFetchURL) async {
        logger.log(level: .debug, message: "DebugFetch: fetching \(entry.hash) -> \(entry.url)", source: "DebugFetchManager")
        do {
            guard let url = URL(string: entry.url) else {
                logger.log(level: .debug, message: "DebugFetch: invalid URL, saving empty response", source: "DebugFetchManager")
                try await firestore.saveDocument(id: entry.hash, data: [
                    "url": entry.url,
                    "response": "",
                    "timestamp": firestore.timestamp
                ])
                return
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            let html = String(data: data, encoding: .utf8) ?? ""
            logger.log(level: .debug, message: "DebugFetch: received \(html.count) chars, minifying...", source: "DebugFetchManager")
            let minified = try minifyHTML(html)
            logger.log(level: .debug, message: "DebugFetch: minified to \(minified.count) chars, saving to Firestore", source: "DebugFetchManager")
            try await firestore.saveDocument(id: entry.hash, data: [
                "url": entry.url,
                "response": minified,
                "timestamp": firestore.timestamp
            ])
            logger.log(level: .debug, message: "DebugFetch: saved \(entry.hash)", source: "DebugFetchManager")
        } catch {
            logger.log(level: .error, message: "DebugFetch store failed for \(entry.url): \(error)", source: "DebugFetchManager")
        }
    }

    private func minifyHTML(_ html: String) throws -> String {
        let doc = try SwiftSoup.parse(html)
        doc.outputSettings().prettyPrint(pretty: false)
        try doc.select("script, style, link[rel=stylesheet]").remove()
        let compact = try doc.body()?.html() ?? ""
        return compact.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
}
