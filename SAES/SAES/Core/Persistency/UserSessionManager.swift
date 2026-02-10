import Foundation

/// Actor that manages user session data with in-memory caching.
/// Provides thread-safe access to user credentials and cookies while minimizing disk reads.
actor UserSessionManager: UserSessionProvider {
    /// Shared singleton instance using default storage and school code provider
    static let shared = UserSessionManager()

    private let storage: LocalStorageClient
    private let schoolCodeProvider: @Sendable () -> String
    private let cacheExpiration: TimeInterval

    private var cachedUser: LocalUserModel?
    private var cacheTimestamp: Date?

    /// Creates a new session manager with dependency injection support.
    /// - Parameters:
    ///   - storage: The storage client for persistence operations
    ///   - schoolCodeProvider: Closure that returns the current school code
    ///   - cacheExpiration: Cache TTL in seconds (default: 5 minutes)
    init(
        storage: LocalStorageClient = LocalStorageAdapter(),
        schoolCodeProvider: @escaping @Sendable () -> String = { UserDefaults.schoolCode },
        cacheExpiration: TimeInterval = 300
    ) {
        self.storage = storage
        self.schoolCodeProvider = schoolCodeProvider
        self.cacheExpiration = cacheExpiration
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
        if let cached = cachedUser, isCacheValid() {
            return cached
        }
        let user = storage.loadUser(currentSchoolCode)
        cachedUser = user
        cacheTimestamp = Date()
        return user
    }

    func saveUser(_ user: LocalUserModel) async {
        guard cachedUser != user else {
            cacheTimestamp = Date()
            return
        }
        storage.saveUser(user.schoolCode, data: user)
        cachedUser = user
        cacheTimestamp = Date()
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
        cachedUser = nil
        cacheTimestamp = nil
    }

    private func isCacheValid() -> Bool {
        guard let timestamp = cacheTimestamp else { return false }
        return Date().timeIntervalSince(timestamp) < cacheExpiration
    }
}
