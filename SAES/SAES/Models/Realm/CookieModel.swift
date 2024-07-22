import Foundation
import RealmSwift

class CookieModel: Object {
    @Persisted var name: String
    @Persisted var path: String
    @Persisted var domain: String
    @Persisted var expireDate: Date?
    @Persisted var value: String
    @Persisted var isHTTPOnly: Bool
    @Persisted var isSecure: Bool
    @Persisted var isSessionOnly: Bool
    @Persisted var version: Int
    
    convenience init(name: String, 
                     path: String,
                     domain: String,
                     expireDate: Date?,
                     value: String,
                     isHTTPOnly: Bool,
                     isSecure: Bool,
                     isSessionOnly: Bool,
                     version: Int) {
        self.init()
        self.name = name
        self.path = path
        self.domain = domain
        self.expireDate = expireDate
        self.value = value
        self.isHTTPOnly = isHTTPOnly
        self.isSecure = isSecure
        self.isSessionOnly = isSessionOnly
        self.version = version
    }
}

extension CookieModel {
    func toHTTPCookie() -> HTTPCookie? {
        return HTTPCookie(properties: [
            .name: self.name,
            .path: self.path,
            .domain: self.domain,
            .expires: self.expireDate ?? "",
            .value: self.value
        ])
    }
}
