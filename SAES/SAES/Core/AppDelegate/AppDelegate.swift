@preconcurrency import Firebase
@preconcurrency import FirebaseMessaging
import UIKit
import WebViewAMC

class AppDelegate: NSObject, UIApplicationDelegate {
    private let logger = Logger(logLevel: .error)

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
        Task { await RemoteConfigManager().fetchRemoteConfig() }
        let bundledJS = JavaScriptConstants.loadBundledJS()
        if !bundledJS.isEmpty {
            WebViewManager.shared.fetcher.defaultJS = [bundledJS]
        }
        Task {
            let remoteJS = await JavaScriptConstants.downloadRemoteJS()
            guard !remoteJS.isEmpty else { return }
            WebViewManager.shared.fetcher.defaultJS = [remoteJS]
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
        logger.log(
            level: .error,
            message: "Failed to register for remote notifications: \(error.localizedDescription)",
            source: "AppDelegate"
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
