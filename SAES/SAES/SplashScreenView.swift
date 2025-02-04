import SwiftUI
import Routing
import SplashScreenAMC

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
        RoutingView(stack: $router.stack) {
            if animationFinished {
                MainView()
                .environmentObject(webViewManager)
                .environmentObject(webViewCoordinator)
                .environmentObject(webViewMessageHandler)
                .environmentObject(router)
                .environment(\.realm, RealmManager.shared.realm)
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
    }
}
