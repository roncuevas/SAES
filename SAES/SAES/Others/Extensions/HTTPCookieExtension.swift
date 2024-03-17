import Foundation

extension HTTPCookie {
    func getDefaultsFormat() -> UserDefaultsCookie {
        return UserDefaultsCookie(name: name,
                                  path: path,
                                  domain: domain,
                                  expiresDate: expiresDate,
                                  value: value,
                                  isHTTPOnly: isHTTPOnly,
                                  isSecure: isSecure,
                                  isSessionOnly: isSessionOnly,
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
