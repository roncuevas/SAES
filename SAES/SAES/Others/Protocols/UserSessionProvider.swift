import Foundation

/// Protocol that abstracts user session management for testability and caching.
/// Implementations provide access to cookies and user data with optional in-memory caching.
protocol UserSessionProvider: Sendable {
    /// Returns cookies as a formatted string for HTTP headers (e.g., "name1=value1; name2=value2")
    func cookiesString() async -> String

    /// Returns the array of cookie models for the current session
    func cookies() async -> [LocalCookieModel]

    /// Returns the current user model if available
    func currentUser() async -> LocalUserModel?

    /// Saves or updates the user model
    func saveUser(_ user: LocalUserModel) async

    /// Updates only the cookies for the current user
    func updateCookies(_ cookies: [LocalCookieModel]) async

    /// Invalidates the in-memory cache, forcing next read from disk
    func invalidateCache() async

    /// The current school code used for storage operations
    var currentSchoolCode: String { get async }
}
