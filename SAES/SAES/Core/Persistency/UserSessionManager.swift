import Foundation

/// Actor that manages user session data.
/// Provides thread-safe access to user credentials and cookies.
/// Caching is delegated to the storage layer (CachedLocalJSON).
actor UserSessionManager: UserSessionProvider {
    /// Shared singleton instance using default storage and school code provider
    static let shared = UserSessionManager()

    private let storage: LocalStorageClient
    private let schoolCodeProvider: @Sendable () -> String

    /// Creates a new session manager with dependency injection support.
    /// - Parameters:
    ///   - storage: The storage client for persistence operations
    ///   - schoolCodeProvider: Closure that returns the current school code
    init(
        storage: LocalStorageClient = LocalStorageAdapter(),
        schoolCodeProvider: @escaping @Sendable () -> String = { UserDefaults.schoolCode }
    ) {
        self.storage = storage
        self.schoolCodeProvider = schoolCodeProvider
    }

    var currentSchoolCode: String {
        schoolCodeProvider()
    }

    func cookiesString() async -> String {
        let cookieList = await cookies()
        return cookieList
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
    }

    func cookies() async -> [LocalCookieModel] {
        guard let user = await currentUser() else { return [] }
        return user.cookie
    }

    func currentUser() async -> LocalUserModel? {
        storage.loadUser(currentSchoolCode)
    }

    func saveUser(_ user: LocalUserModel) async {
        storage.saveUser(user.schoolCode, data: user)
    }

    func updateCookies(_ cookies: [LocalCookieModel]) async {
        guard let user = await currentUser(),
              user.cookie != cookies else { return }
        let updatedUser = LocalUserModel(
            schoolCode: user.schoolCode,
            studentID: user.studentID,
            password: user.password,
            ivValue: user.ivValue,
            cookie: cookies
        )
        await saveUser(updatedUser)
    }

    func invalidateCache() async {
        storage.invalidateCache(for: currentSchoolCode)
    }
}
