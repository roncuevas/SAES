import Foundation

struct LocalCookieModel: Codable, Equatable, Sendable {
    let domain: String
    let hostOnly: Bool
    let httpOnly: Bool
    let name: String
    let path: String
    let sameSite: String
    let secure: Bool
    let session: Bool
    let storeId: String
    let value: String
    let id: Int
}

extension LocalCookieModel {
    var httpCookie: HTTPCookie? {
        let properties: [HTTPCookiePropertyKey: Any] = [
            .domain: domain,
            .path: path,
            .name: name,
            .value: value,
            .secure: secure,
            .version: 0
        ]
        return HTTPCookie(properties: properties)
    }
}

extension Array where Element == LocalCookieModel {
    var httpCookies: [HTTPCookie] {
        self.compactMap { $0.httpCookie }
    }
}
