import Foundation

struct UserDefaultsCookie: Codable {
    let name: String
    let path: String
    let domain: String
    let expiresDate: Date?
    let value: String
    let isHTTPOnly: Bool
    let isSecure: Bool
    let isSessionOnly: Bool
    let version: Int
}
