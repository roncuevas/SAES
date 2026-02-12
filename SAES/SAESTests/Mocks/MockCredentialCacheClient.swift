import Foundation
@testable import SAES

final class MockCredentialCacheClient: CredentialCacheClient, @unchecked Sendable {
    var cachedData: [String: CredentialWebData] = [:]
    var loadCallCount = 0
    var saveCallCount = 0
    var deleteCallCount = 0
    var lastDeletedSchoolCode: String?

    func load(_ schoolCode: String) -> CredentialWebData? {
        loadCallCount += 1
        return cachedData[schoolCode]
    }

    func save(_ schoolCode: String, data: CredentialWebData) {
        saveCallCount += 1
        cachedData[schoolCode] = data
    }

    func delete(_ schoolCode: String) {
        deleteCallCount += 1
        lastDeletedSchoolCode = schoolCode
        cachedData.removeValue(forKey: schoolCode)
    }
}
