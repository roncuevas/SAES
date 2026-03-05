import Foundation

enum DeepLinkHandler {
    static func handle(_ url: URL) {
        guard url.scheme == "saes" else { return }
        switch url.host {
        case "enableDebugSettings":
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.debugSettingsEnabled)
        case "disableDebugSettings":
            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.debugSettingsEnabled)
        default:
            break
        }
    }
}
