import Foundation
import WebViewAMC

@MainActor
final class SettingsViewModel: ObservableObject {
    private let localStorage: LocalStorageClient
    private let credentialStorage: CredentialStorageClient
    private let credentialCache: CredentialCacheClient
    private let userDefaults: UserDefaults
    private let persistentDomainName: String?

    init(
        localStorage: LocalStorageClient = LocalStorageAdapter(),
        credentialStorage: CredentialStorageClient = CredentialStorageAdapter(),
        credentialCache: CredentialCacheClient = CredentialCacheManager(),
        userDefaults: UserDefaults = .standard,
        persistentDomainName: String? = Bundle.main.bundleIdentifier
    ) {
        self.localStorage = localStorage
        self.credentialStorage = credentialStorage
        self.credentialCache = credentialCache
        self.userDefaults = userDefaults
        self.persistentDomainName = persistentDomainName
    }

    func resetConfiguration(
        webViewHandler: WebViewHandler,
        router: Router<NavigationRoutes>
    ) {
        WebViewManager.shared.webView.removeCookies([
            AppConstants.CookieNames.aspxFormsAuth
        ])

        webViewHandler.clearData()

        if let domainName = persistentDomainName {
            userDefaults.removePersistentDomain(forName: domainName)
        }

        router.navigateToRoot()
    }

    func deleteAllData(
        webViewHandler: WebViewHandler,
        router: Router<NavigationRoutes>
    ) {
        let schoolCode = userDefaults.string(
            forKey: AppConstants.UserDefaultsKeys.schoolCode
        ) ?? ""

        if !schoolCode.isEmpty {
            localStorage.deleteUser(schoolCode)
            credentialStorage.deleteCredential(schoolCode)
            credentialCache.delete(schoolCode)
        }

        resetConfiguration(webViewHandler: webViewHandler, router: router)
    }
}
