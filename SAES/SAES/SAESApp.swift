import SwiftUI
import Inject

@main
struct SAESApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @AppStorage(AppConstants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = "dark"

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(colorScheme)
        }
    }

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}
