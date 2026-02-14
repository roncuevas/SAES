import Foundation
import WebViewAMC

@MainActor
final class SettingsViewModel: ObservableObject {
    private let localStorage: LocalStorageClient
    private let credentialStorage: CredentialStorageClient
    private let credentialCache: CredentialCacheClient
    private let userDefaults: UserDefaults
    private let persistentDomainName: String?
    private let proxy: WebViewProxy

    init(
        localStorage: LocalStorageClient = LocalStorageAdapter(),
        credentialStorage: CredentialStorageClient = CredentialStorageAdapter(),
        credentialCache: CredentialCacheClient = CredentialCacheManager(),
        userDefaults: UserDefaults = .standard,
        persistentDomainName: String? = Bundle.main.bundleIdentifier,
        proxy: WebViewProxy? = nil
    ) {
        self.localStorage = localStorage
        self.credentialStorage = credentialStorage
        self.credentialCache = credentialCache
        self.userDefaults = userDefaults
        self.persistentDomainName = persistentDomainName
        self.proxy = proxy ?? WebViewProxy()
    }

    func resetConfiguration(
        webViewHandler: WebViewHandler,
        onComplete: () -> Void
    ) {
        Task {
            await proxy.cookieManager.removeCookies(named: [
                AppConstants.CookieNames.aspxFormsAuth
            ])
        }

        webViewHandler.clearData()

        if let domainName = persistentDomainName {
            userDefaults.removePersistentDomain(forName: domainName)
        }

        onComplete()
    }

    func deleteAllData(
        webViewHandler: WebViewHandler,
        onComplete: () -> Void
    ) {
        let schoolCode = userDefaults.string(
            forKey: AppConstants.UserDefaultsKeys.schoolCode
        ) ?? ""

        if !schoolCode.isEmpty {
            localStorage.deleteUser(schoolCode)
            credentialStorage.deleteCredential(schoolCode)
            credentialCache.delete(schoolCode)
        }

        resetConfiguration(webViewHandler: webViewHandler, onComplete: onComplete)
    }
}
