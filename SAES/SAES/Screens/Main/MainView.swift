import Routing
import SwiftUI
import WebViewAMC

struct MainView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewHandler: WebViewHandler

    var body: some View {
        if isSetted {
            LoginView()
                .alert("Timeout", isPresented: $webViewHandler.isTimeout, actions: {
                    Button("Go back") {
                        webViewHandler.isTimeout = false
                        isSetted = false
                    }
                    Button("Refresh") {
                        webViewHandler.isTimeout = false
                        WebViewManager.shared.webView.loadURL(id: "refresh",
                                                              url: URLConstants.home.value,
                                                              forceRefresh: true)
                    }
                }, message: {
                    Text("The page took too long to load.")
                })
                .onChange(of: isLogged) { newValue in
                    if newValue, router.stack.last != .logged {
                        router.navigate(to: .logged)
                        do {
                            try AnalyticsManager.shared.sendData()
                        } catch {
                            print(error)
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
