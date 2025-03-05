import Foundation
import UIKit
@_exported import PostHog

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let posthogApiKey = ProcessInfo.processInfo.environment["POSTHOG_API_KEY"]!
        let posthogHost = "https://us.i.posthog.com"
        let config = PostHogConfig(apiKey: posthogApiKey, host: posthogHost)
        PostHogSDK.shared.setup(config)
        return true
    }
}
