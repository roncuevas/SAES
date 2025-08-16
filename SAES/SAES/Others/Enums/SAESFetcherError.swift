import Foundation

enum SAESFetcherError: Error, LocalizedError {
    case userLoggedOut

    var errorDescription: String? {
        switch self {
        case .userLoggedOut:
            return "The user is not logged in (validated via HTML Title)."
        }
    }
}
