import SwiftUI
@_exported import Inject

@main
struct SAESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
