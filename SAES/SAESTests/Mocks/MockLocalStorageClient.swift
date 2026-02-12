import Foundation
@testable import SAES

/// Mock implementation of LocalStorageClient for testing UserSessionManager
final class MockLocalStorageClient: LocalStorageClient, @unchecked Sendable {
    var storedUsers: [String: LocalUserModel] = [:]
    var loadUserCallCount = 0
    var saveUserCallCount = 0
    var invalidateCacheCallCount = 0
    var deleteUserCallCount = 0
    var lastInvalidatedSchoolCode: String?

    func loadUser(_ schoolCode: String) -> LocalUserModel? {
        loadUserCallCount += 1
        return storedUsers[schoolCode]
    }

    func saveUser(_ schoolCode: String, data: LocalUserModel) {
        saveUserCallCount += 1
        storedUsers[schoolCode] = data
    }

    func invalidateCache(for schoolCode: String) {
        invalidateCacheCallCount += 1
        lastInvalidatedSchoolCode = schoolCode
    }

    func deleteUser(_ schoolCode: String) {
        deleteUserCallCount += 1
        storedUsers.removeValue(forKey: schoolCode)
    }
}
