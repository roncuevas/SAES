import Foundation
@testable import SAES

final class MockCredentialStorageClient: CredentialStorageClient, @unchecked Sendable {
    var storedCredentials: [String: CredentialModel] = [:]
    var loadCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var lastDeletedSchoolCode: String?

    func loadCredential(_ schoolCode: String) -> CredentialModel? {
        loadCallCount += 1
        return storedCredentials[schoolCode]
    }

    func saveCredential(_ schoolCode: String, data: CredentialModel) {
        saveCallCount += 1
        storedCredentials[schoolCode] = data
    }

    func deleteCredential(_ schoolCode: String) {
        deleteCallCount += 1
        lastDeletedSchoolCode = schoolCode
        storedCredentials.removeValue(forKey: schoolCode)
    }
}
