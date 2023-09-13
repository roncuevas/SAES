import Foundation

extension HTTPCookie {
    func getDefaultsFormat() -> UserDefaultsCookie {
        return UserDefaultsCookie(name: name,
                                  path: path,
                                  domain: domain,
                                  comment: comment,
                                  commentURL: commentURL,
                                  expiresDate: expiresDate,
                                  isHTTPOnly: isHTTPOnly,
                                  isSecure: isSecure,
                                  isSessionOnly: isSessionOnly,
                                  portList: portList,
                                  properties: properties,
                                  sameSitePolicy: sameSitePolicy,
                                  version: version)
    }
}

extension [HTTPCookie] {
    func getDefaultsFormat() -> [UserDefaultsCookie] {
        var array: [UserDefaultsCookie] = []
        for cookie in self {
            array.append(cookie.getDefaultsFormat())
        }
        return array
    }
}

struct UserDefaultsCookie {
    let name: String
    let path: String
    let domain: String
    let comment: String?
    let commentURL: URL?
    let expiresDate: Date?
    let isHTTPOnly: Bool
    let isSecure: Bool
    let isSessionOnly: Bool
    let portList: [NSNumber]?
    let properties: [HTTPCookiePropertyKey: Any]?
    let sameSitePolicy: HTTPCookieStringPolicy?
    let version: Int
}

struct CookieStorage {
    let cookies: [UserDefaultsCookie]?
}
