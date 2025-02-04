import SwiftUI
import Routing
import SplashScreenAMC
import WebViewAMC

struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewManager: WebViewManager = WebViewManager.shared
    @StateObject private var webViewHandler: WebViewHandler = WebViewHandler.shared
    @StateObject private var router: Router<NavigationRoutes> = .init()
    private let webViewDataFetcher: WebViewDataFetcher = WebViewDataFetcher()
    
    init() {
        webViewManager.messageHandler.delegate = webViewHandler
        webViewManager.coordinator.delegate = webViewHandler
    }
    
    var body: some View {
        RoutingView(stack: $router.stack) {
            if animationFinished {
                MainView()
                    .task {
                        await webViewDataFetcher.fetchLoggedAndErrors()
                    }
            } else {
                SplashScreenCreator(fileName: colorScheme == .light ? "SAES" : "SAESblack",
                                    animationSpeed: EnvironmentConstants.animationSpeed,
                                    animationCompleted: $animationFinished)
                .frame(width: 200, height: 200)
            }
        }
        .environmentObject(webViewManager)
        .environmentObject(webViewHandler)
        .environmentObject(router)
    }
}
