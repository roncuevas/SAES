import SwiftUI
import Routing

struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewManager: WebViewManager = WebViewManager.shared
    @StateObject private var router: Router<NavigationRoutes> = .init()
    
    var body: some View {
        if animationFinished {
            RoutingView(stack: $router.stack) {
                MainView()
            }
            .environmentObject(webViewManager)
            .environmentObject(router)
        } else {
            lottieView
        }
    }
    
    var lottieView: some View {
        LottieView(animationFinished: $animationFinished,
                   name: colorScheme == .light ? "SAES" : "SAESblack",
                   animationSpeed: EnvironmentConstants.animationSpeed)
            .frame(width: 220, height: 220)
    }
}
