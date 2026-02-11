import Foundation
import LocalJSON

/// Default implementation of LocalStorageClient that wraps LocalJSON for file persistence.
/// This adapter is Sendable as LocalJSON operations are self-contained.
final class LocalStorageAdapter: LocalStorageClient, @unchecked Sendable {
    private let logger = Logger(logLevel: .error)
    private let storage = LocalJSON()

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
}
