import Foundation

/// Protocol that abstracts local file storage operations for testability.
/// Implementations wrap the actual storage mechanism (e.g., LocalJSON).
protocol LocalStorageClient: Sendable {
    /// Loads user data from storage for the given school code
    func loadUser(_ schoolCode: String) -> LocalUserModel?

    /// Saves user data to storage for the given school code
    func saveUser(_ schoolCode: String, data: LocalUserModel)

    /// Invalidates any cached data for the given school code
    func invalidateCache(for schoolCode: String)
}
