import Foundation

extension HTTPCookie {
    func getDefaultsFormat() -> CookieModel {
        return CookieModel(name: name,
                           path: path,
                           domain: domain,
                           expireDate: expiresDate,
                           value: value,
                           isHTTPOnly: isHTTPOnly,
                           isSecure: isSecure,
                           isSessionOnly: isSessionOnly,
                           version: version)
    }
}
