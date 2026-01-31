import Foundation
import LocalJSON

final class LocalStorageManager {
    private static let logger = Logger(logLevel: .error)

    static func loadLocalUser(_ schoolCode: String) -> LocalUserModel? {
        do {
            return try LocalJSON.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
        return nil
    }

    static func saveLocalUser(_ schoolCode: String, data: LocalUserModel) {
        do {
            try LocalJSON.writeJSON(data: data, to: "\(schoolCode).json")
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
    }

    static func loadLocalCookies(_ schoolCode: String) -> [LocalCookieModel] {
        do {
            let user = try LocalJSON.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
            return user.cookie
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
        return []
    }

    static func loadLocalCookies(_ schoolCode: String) -> String {
        return loadLocalCookies(schoolCode)
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
    }

    private func loadCookies(_ cookies: [LocalCookieModel]) {
        let cookieStorage = HTTPCookieStorage.shared
        cookies.compactMap { $0.httpCookie }.forEach { cookieStorage.setCookie($0) }
    }
}
