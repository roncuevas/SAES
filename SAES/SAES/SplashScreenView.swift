import SwiftUI
import Routing
import SplashScreenAMC

struct SplashScreenView: View {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewHandler = WebViewHandler.shared
    @StateObject private var router = Router<NavigationRoutes>()
    
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
        .navigationViewStyle(.stack)
        .environmentObject(webViewHandler)
        .environmentObject(router)
        .onAppear {
            isLogged = false
        }
    }
}
