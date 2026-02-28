import SwiftUI

@MainActor
final class TabManager: ObservableObject {
    static let shared = TabManager()

    @Published var selectedTab: LoggedTabs

    private init() {
        let saved = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.defaultTab)
            ?? LoggedTabs.home.rawValue
        selectedTab = LoggedTabs(rawValue: saved) ?? .home
    }

    func switchTo(_ tab: LoggedTabs) {
        selectedTab = tab
    }
}
