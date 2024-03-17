import Foundation

extension UserDefaultsCookie {
    func getHTTPCookie() -> HTTPCookie? {
        return HTTPCookie(properties: [
            .name: self.name,
            .path: self.path,
            .domain: self.domain,
            .expires: self.expiresDate ?? "",
            .value: self.value
        ])
    }
}
