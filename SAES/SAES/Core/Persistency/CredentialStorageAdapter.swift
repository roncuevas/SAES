import Foundation
import LocalJSON

final class CredentialStorageAdapter: CredentialStorageClient, @unchecked Sendable {
    private let logger = Logger(logLevel: .error)
    private let storage: CachedLocalJSON

    init(storage: CachedLocalJSON = CachedLocalJSON(wrapping: LocalJSON())) {
        self.storage = storage
    }

    func loadCredential(_ schoolCode: String) -> CredentialModel? {
        do {
            return try storage.getJSON(from: "credential_\(schoolCode).json", as: CredentialModel.self)
        } catch {
            if !(error is LocalJSONError) {
                logger.log(level: .error, message: "\(error)", source: "CredentialStorageAdapter")
            }
        }
        return nil
    }

    func saveCredential(_ schoolCode: String, data: CredentialModel) {
        do {
            try storage.writeJSON(data: data, to: "credential_\(schoolCode).json")
        } catch {
            logger.log(level: .error, message: "\(error)", source: "CredentialStorageAdapter")
        }
    }

    func deleteCredential(_ schoolCode: String) {
        do {
            try storage.delete(file: "credential_\(schoolCode).json")
        } catch {
            if !(error is LocalJSONError) {
                logger.log(level: .error, message: "\(error)", source: "CredentialStorageAdapter")
            }
        }
    }
}
