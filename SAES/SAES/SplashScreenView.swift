import SwiftUI
import Routing
import SplashScreenAMC
import WebViewAMC

struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewHandler: WebViewHandler = WebViewHandler.shared
    @StateObject private var router: Router<NavigationRoutes> = .init()
    init() {
        WebViewManager.shared.handler.delegate = webViewHandler
        WebViewManager.shared.coordinator.delegate = webViewHandler
    }
    
    var body: some View {
        RoutingView(stack: $router.stack) {
            if animationFinished {
                MainView()
            } else {
                SplashScreenCreator(fileName: colorScheme == .light ? "SAES" : "SAESblack",
                                    animationSpeed: EnvironmentConstants.animationSpeed,
                                    animationCompleted: $animationFinished)
                .frame(width: 200, height: 200)
            }
        }
        .environmentObject(webViewHandler)
        .environmentObject(router)
    }
}
