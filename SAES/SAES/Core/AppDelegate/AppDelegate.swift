import Firebase
import FirebaseMessaging
import UIKit
import WebViewAMC

class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        RemoteConfigManager().fetchRemoteConfig()
        let encryptedLocalJS = JavaScriptConstants.loadCommonJS()
        if let decryptedJS = CryptoSwiftManager.decryptScrapperJS(encryptedLocalJS) {
            WebViewManager.shared.fetcher.defaultJS = [decryptedJS]
        }
        Task {
            let encryptedJS = await JavaScriptConstants.getCommonJS()
            guard let decryptedJS = CryptoSwiftManager.decryptScrapperJS(encryptedJS) else { return }
            WebViewManager.shared.fetcher.defaultJS = [decryptedJS]
        }
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        debugPrint(
            "Failed to register for remote notifications: \(error.localizedDescription)"
        )
    }

    static func apnsToken() -> String {
        let deviceToken: Data = Messaging.messaging().apnsToken ?? Data()
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }
            .joined()
        return tokenString
    }

    static func fcmToken() -> String {
        Messaging.messaging().fcmToken ?? ""
    }
}
