import Foundation

extension Array where Element == HTTPCookie {
    var toLocalCookies: [LocalCookieModel] {
        return self.map {
            LocalCookieModel(
                domain: $0.domain,
                hostOnly: !$0.domain.hasPrefix("."),
                httpOnly: $0.isHTTPOnly,
                name: $0.name,
                path: $0.path,
                sameSite: "unspecified", // HTTPCookie no expone SameSite directamente
                secure: $0.isSecure,
                session: $0.expiresDate == nil,
                storeId: "0",
                value: $0.value,
                id: $0.hashValue
            )
        }
    }
}
