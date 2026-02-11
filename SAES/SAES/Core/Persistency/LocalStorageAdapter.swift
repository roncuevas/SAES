import Foundation
import LocalJSON

/// Default implementation of LocalStorageClient that wraps CachedLocalJSON for file persistence.
/// CachedLocalJSON provides read caching with TTL, write deduplication, and LRU eviction.
final class LocalStorageAdapter: LocalStorageClient, @unchecked Sendable {
    private let logger = Logger(logLevel: .error)
    private let storage: CachedLocalJSON

    init(storage: CachedLocalJSON = CachedLocalJSON(wrapping: LocalJSON())) {
        self.storage = storage
    }

    func loadUser(_ schoolCode: String) -> LocalUserModel? {
        do {
            return try storage.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageAdapter")
        }
        return nil
    }

    func saveUser(_ schoolCode: String, data: LocalUserModel) {
        do {
            try storage.writeJSON(data: data, to: "\(schoolCode).json")
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageAdapter")
        }
    }

    func invalidateCache(for schoolCode: String) {
        storage.invalidate(file: "\(schoolCode).json")
    }
}
