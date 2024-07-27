import SwiftUI
import Routing

struct SplashScreenView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewManager: WebViewManager = WebViewManager.shared
    @StateObject private var webViewMessageHandler: WebViewMessageHandler = WebViewMessageHandler.shared
    @StateObject private var webViewCoordinator: WebViewCoordinator = WebViewCoordinator.shared
    @StateObject private var router: Router<NavigationRoutes> = .init()
    private let webViewDataFetcher: WebViewDataFetcher = WebViewDataFetcher()
    
    init() {
        webViewManager.handler.delegate = webViewMessageHandler
    }
    
    var body: some View {
        if animationFinished {
            RoutingView(stack: $router.stack) {
                MainView()
            }
            .environmentObject(webViewManager)
            .environmentObject(webViewCoordinator)
            .environmentObject(webViewMessageHandler)
            .environmentObject(router)
            .task {
                await webViewDataFetcher.fetchLoggedAndErrors()
            }
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
