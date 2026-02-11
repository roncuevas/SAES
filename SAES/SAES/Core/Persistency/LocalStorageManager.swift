import Foundation
import LocalJSON

/// Legacy storage manager - use UserSessionManager instead for new code.
/// This class is deprecated and will be removed in a future version.
final class LocalStorageManager {
    private static let logger = Logger(logLevel: .error)
    private static let storage = LocalJSON()

    @available(*, deprecated, message: "Use UserSessionManager.shared.currentUser() instead")
    static func loadLocalUser(_ schoolCode: String) -> LocalUserModel? {
        do {
            return try storage.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
        return nil
    }

    @available(*, deprecated, message: "Use UserSessionManager.shared.saveUser(_:) instead")
    static func saveLocalUser(_ schoolCode: String, data: LocalUserModel) {
        do {
            try storage.writeJSON(data: data, to: "\(schoolCode).json")
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
    }

    @available(*, deprecated, message: "Use UserSessionManager.shared.cookies() instead")
    static func loadLocalCookies(_ schoolCode: String) -> [LocalCookieModel] {
        do {
            let user = try storage.getJSON(from: "\(schoolCode).json", as: LocalUserModel.self)
            return user.cookie
        } catch {
            logger.log(level: .error, message: "\(error)", source: "LocalStorageManager")
        }
        return []
    }

    @available(*, deprecated, message: "Use UserSessionManager.shared.cookiesString() instead")
    static func loadLocalCookies(_ schoolCode: String) -> String {
        return loadLocalCookies(schoolCode)
            .map { "\($0.name)=\($0.value)" }
            .joined(separator: "; ")
    }
}
