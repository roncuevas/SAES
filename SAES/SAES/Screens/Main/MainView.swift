import Routing
import StoreKit
import SwiftUI
import WebViewAMC

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @AppStorage("loggedCounter") private var loggedCounter: Int = 0
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewHandler: WebViewHandler

    var body: some View {
        if isSetted {
            LoginView()
                .alert(Localization.timeout, isPresented: $webViewHandler.isTimeout, actions: {
                    Button(Localization.goBack) {
                        webViewHandler.isTimeout = false
                        isSetted = false
                    }
                    Button(Localization.refresh) {
                        webViewHandler.isTimeout = false
                        WebViewManager.shared.webView.loadURL(id: "refresh",
                                                              url: URLConstants.home.value,
                                                              forceRefresh: true)
                    }
                }, message: {
                    Text(Localization.timeoutMessage)
                })
                .onChange(of: isLogged) { newValue in
                    if newValue, router.stack.last != .logged {
                        loggedCounter += 1
                        router.navigate(to: .logged)
                        do {
                            try AnalyticsManager.shared.sendData()
                        } catch {
                            print(error)
                        }
                        if loggedCounter > 3 && Bool.random() {
                            Task {
                                try await Task.sleep(nanoseconds: 5_000_000)
                                requestReview()
                            }
                        }
                    } else if newValue == false {
                        router.navigateBack()
                    }
                }
        } else {
            SetupView()
                .onAppear {
                    WebViewManager.shared.webView.loadURL(id: "refresh", url: "https://www.ipn.mx/")
                    webViewHandler.clearData()
                }
        }
    }
}
