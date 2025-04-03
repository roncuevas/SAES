import Foundation
import LocalJSON

final class LocalStorageManager {

    static func loadLocalUser(_ schoolCode: String) -> LocalUserModel? {
        do {
            return try LocalJSON.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
        } catch {
            print(error)
        }
        return nil
    }

    static func saveLocalUser(_ schoolCode: String, data: LocalUserModel) {
        do {
            try LocalJSON.writeJSON(data: data, to: "\(schoolCode).json")
        } catch {
            print(error)
        }
    }

    static func loadLocalCookies(_ schoolCode: String) -> [LocalCookieModel] {
        do {
            let user = try LocalJSON.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
            return user.cookie
        } catch {
            print(error)
        }
        return []
    }

    private func loadCookies(_ cookies: [LocalCookieModel]) {
        let cookieStorage = HTTPCookieStorage.shared
        cookies.compactMap { $0.httpCookie }.forEach { cookieStorage.setCookie($0) }
    }
}
