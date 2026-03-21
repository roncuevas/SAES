import AppRouter
import SwiftUI
import Lottie
import WebViewAMC

struct SplashScreenView: View {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var animationFinished: Bool = false
    @State private var progress: CGFloat = 0.0

    private var animationDuration: Double {
        (240.0 / 60.0) / Double(EnvironmentConstants.animationSpeed)
    }

    @ObservedObject private var webViewHandler = WebViewHandler.shared
    @StateObject private var proxy = WebViewProxy()
    @StateObject private var router = AppRouter()
    @ObservedObject private var toastManager = ToastManager.shared
    @ObservedObject private var deepLinkManager = DeepLinkManager.shared

    var body: some View {
        ZStack {
            HeadlessWebView()
            NavigationStack(path: $router.path) {
                Group {
                    if animationFinished {
                        MainView()
                    } else {
                        VStack(spacing: 0) {
                            Spacer()
                            LottieView(animation: .named(colorScheme == .light ? "SAES" : "SAESblack"))
                                .playing(.fromProgress(0, toProgress: 1, loopMode: .playOnce))
                                .animationSpeed(EnvironmentConstants.animationSpeed)
                                .animationDidFinish { completed in
                                    if completed {
                                        animationFinished = true
                                    }
                                }
                                .configure { animationView in
                                    animationView.respectAnimationFrameRate = true
                                    animationView.shouldRasterizeWhenIdle = true
                                }
                                .frame(width: 200, height: 200)
                            Text("SAES")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .kerning(4)
                                .foregroundStyle(.primary)
                            Text("para alumnos")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                            Spacer()
                            ProgressView(value: progress)
                                .progressViewStyle(.linear)
                                .tint(.saes)
                                .frame(width: 200)
                                .padding(.bottom, 60)
                        }
                        .onAppear {
                            withAnimation(.linear(duration: animationDuration)) {
                                progress = 1.0
                            }
                        }
                    }
                }
                .navigationDestination(for: AppDestination.self) { $0.destinationView }
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
        .environmentObject(router)
        .onChange(of: deepLinkManager.pendingURL) { url in
            guard let url, animationFinished else { return }
            processDeepLink(url)
        }
        .onChange(of: animationFinished) { finished in
            if finished, let url = deepLinkManager.pendingURL {
                processDeepLink(url)
            }
        }
        .task {
            guard UserDefaults.standard.bool(forKey: "isSetted"),
                  await UserSessionManager.shared.currentUser() != nil else {
                isLogged = false
                return
            }
            if await WebViewActions.shared.isStillLogged() {
                let cookies = await UserSessionManager.shared.cookies()
                proxy.cookieManager.setCookiesSync(cookies.httpCookies)
                isLogged = true
            } else {
                isLogged = false
            }
        }
    }

    private func processDeepLink(_ url: URL) {
        let action = DeepLinkHandler.classify(url)
        deepLinkManager.consume()

        switch action {
        case .tab(let tab):
            guard isLogged else { return }
            TabManager.shared.switchTo(tab)
        case .destination(let destination):
            router.navigateTo(destination)
        case .none:
            break
        }
    }
}
