import Foundation
import RealmSwift

extension HTTPCookie {
    func toCookieModel() -> CookieModel {
        return CookieModel(id: UserDefaults.schoolCode + UserDefaults.user + name,
                           name: name,
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

extension [HTTPCookie] {
    func toCookieModelList() -> List<CookieModel> {
        let list = List<CookieModel>()
        self.forEach { httpcookie in
            list.append(httpcookie.toCookieModel())
        }
        return list
    }
}
