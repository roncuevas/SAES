import Foundation
@testable import SAES

/// Mock implementation of LocalStorageClient for testing UserSessionManager
final class MockLocalStorageClient: LocalStorageClient, @unchecked Sendable {
    var storedUsers: [String: LocalUserModel] = [:]
    var loadUserCallCount = 0
    var saveUserCallCount = 0

    func loadUser(_ schoolCode: String) -> LocalUserModel? {
        loadUserCallCount += 1
        return storedUsers[schoolCode]
    }

    func saveUser(_ schoolCode: String, data: LocalUserModel) {
        saveUserCallCount += 1
        storedUsers[schoolCode] = data
    }
}
