import SwiftUI
import NavigatorUI
import Lottie
import WebViewAMC

struct SplashScreenView: View {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @ObservedObject private var webViewHandler = WebViewHandler.shared
    @StateObject private var proxy = WebViewProxy()
    @ObservedObject private var toastManager = ToastManager.shared

    var body: some View {
        ZStack {
            HeadlessWebView()
            ManagedNavigationStack {
                if animationFinished {
                    MainView()
                } else {
                    LottieView(animation: .named(colorScheme == .light ? "SAES" : "SAESblack"))
                        .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                        .animationSpeed(EnvironmentConstants.animationSpeed)
                        .animationDidFinish { completed in
                            if completed {
                                animationFinished = true
                            }
                        }
                        .frame(width: 200, height: 200)
                }
            }
            .toast(
                $toastManager.toastToPresent,
                style: ToastSAESStyle(),
                edge: .bottom,
                isAutoDismissed: toastManager.autoDismissable
            )
        }
        .environmentObject(proxy)
        .environmentObject(webViewHandler)
        .onAppear {
            isLogged = false
        }
    }
}
