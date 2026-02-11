import Foundation

protocol CredentialStorageClient: Sendable {
    func loadCredential(_ schoolCode: String) -> CredentialModel?
    func saveCredential(_ schoolCode: String, data: CredentialModel)
    func deleteCredential(_ schoolCode: String)
}
