import Foundation
@testable import SAES

/// Mock implementation of UserSessionProvider for testing ViewModels and DataSources
actor MockUserSessionProvider: UserSessionProvider {
    var mockUser: LocalUserModel?
    var mockCookies: [LocalCookieModel] = []
    var mockSchoolCode: String = "test"
    var saveUserCallCount = 0
    var updateCookiesCallCount = 0
    var invalidateCacheCallCount = 0

    var currentSchoolCode: String {
        mockSchoolCode
    }

    func cookiesString() async -> String {
        mockCookies
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
    }

    func cookies() async -> [LocalCookieModel] {
        mockCookies
    }

    func currentUser() async -> LocalUserModel? {
        mockUser
    }

    func saveUser(_ user: LocalUserModel) async {
        saveUserCallCount += 1
        mockUser = user
    }

    func updateCookies(_ cookies: [LocalCookieModel]) async {
        updateCookiesCallCount += 1
        mockCookies = cookies
    }

    func invalidateCache() async {
        invalidateCacheCallCount += 1
    }
}
