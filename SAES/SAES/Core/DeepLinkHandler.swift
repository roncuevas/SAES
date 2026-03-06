import Foundation

@MainActor
enum DeepLinkHandler {
    enum NavigationAction {
        case tab(LoggedTabs)
        case destination(AppDestination)
        case none
    }

    static func handle(_ url: URL) {
        guard url.scheme == "saes" else { return }
        switch url.host {
        case "enableDebugSettings":
            UserDefaults.standard.set(true, forKey: AppConstants.UserDefaultsKeys.debugSettingsEnabled)
        case "disableDebugSettings":
            UserDefaults.standard.set(false, forKey: AppConstants.UserDefaultsKeys.debugSettingsEnabled)
        default:
            DeepLinkManager.shared.enqueue(url)
        }
    }

    static func classify(_ url: URL) -> NavigationAction {
        guard url.scheme == "saes", let host = url.host else { return .none }
        if let tab = LoggedTabs(rawValue: host) {
            return .tab(tab)
        }
        if let destination = AppDestination.from(path: host, fullPath: [host], parameters: [:]) {
            return .destination(destination)
        }
        return .none
    }
}
