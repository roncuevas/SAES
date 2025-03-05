import SwiftUI
@_exported import Inject
@_exported import os

@main
struct SAESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
