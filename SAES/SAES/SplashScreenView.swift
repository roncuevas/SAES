import SwiftUI
import Navigation
import SplashScreenAMC
import WebViewAMC

struct SplashScreenView: View {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @StateObject private var webViewHandler = WebViewHandler.shared
    @StateObject private var proxy = WebViewProxy()
    @StateObject private var router = Router<NavigationRoutes>()
    @ObservedObject private var toastManager = ToastManager.shared

    var body: some View {
        ZStack {
            HeadlessWebView()
            Navigator(path: $router.stack) {
                if animationFinished {
                    MainView()
                } else {
                    SplashScreenCreator(fileName: colorScheme == .light ? "SAES" : "SAESblack",
                                        animationSpeed: EnvironmentConstants.animationSpeed,
                                        animationCompleted: $animationFinished)
                    .frame(width: 200, height: 200)
                }
            }
            .toast(
                $toastManager.toastToPresent,
                style: ToastSAESStyle(),
                edge: .bottom,
                isAutoDismissed: toastManager.autoDismissable
            )
            .navigationViewStyle(.stack)
        }
        .environmentObject(proxy)
        .environmentObject(webViewHandler)
        .environmentObject(router)
        .onAppear {
            isLogged = false
        }
    }
}
