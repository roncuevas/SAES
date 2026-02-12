import Foundation
import LocalJSON

final class CredentialCacheManager: CredentialCacheClient, @unchecked Sendable {
    private let logger = Logger(logLevel: .error)
    private let storage: CachedLocalJSON

    init(storage: CachedLocalJSON = CachedLocalJSON(wrapping: LocalJSON())) {
        self.storage = storage
    }

    func load(_ schoolCode: String) -> CredentialWebData? {
        do {
            return try storage.getJSON(from: fileName(for: schoolCode), as: CredentialWebData.self)
        } catch is LocalJSONError {
            return nil
        } catch {
            logger.log(level: .error, message: "\(error)", source: "CredentialCacheManager")
        }
        return nil
    }

    func save(_ schoolCode: String, data: CredentialWebData) {
        do {
            try storage.writeJSON(data: data, to: fileName(for: schoolCode))
        } catch {
            logger.log(level: .error, message: "\(error)", source: "CredentialCacheManager")
        }
    }

    func delete(_ schoolCode: String) {
        do {
            try storage.delete(file: fileName(for: schoolCode))
        } catch is LocalJSONError {
            return
        } catch {
            logger.log(level: .error, message: "\(error)", source: "CredentialCacheManager")
        }
    }

    private func fileName(for schoolCode: String) -> String {
        "credential_cache_\(schoolCode).json"
    }
}
