import SwiftUI
import Routing

struct SplashScreenView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var animationFinished: Bool = false
    @State var isPresenting: Bool = false
    @StateObject var webViewManager: WebViewManager = WebViewManager()
    @StateObject private var router: Router<NavigationRoute> = .init()
    
    var body: some View {
        if animationFinished {
            RoutingView(stack: $router.stack) {
                MainView()
                    .environmentObject(webViewManager)
            }
        } else {
            LottieView(animationFinished: $animationFinished,
                       name: colorScheme == .light ? "SAES" : "SAESblack",
                       animationSpeed: EnvironmentConstants.animationSpeed)
                .frame(width: 220, height: 220)
        }
    }
}
