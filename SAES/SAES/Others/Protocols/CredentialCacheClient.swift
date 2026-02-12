import Foundation

protocol CredentialCacheClient: Sendable {
    func load(_ schoolCode: String) -> CredentialWebData?
    func save(_ schoolCode: String, data: CredentialWebData)
    func delete(_ schoolCode: String)
}
