import FirebaseRemoteConfig
import Routing
import StoreKit
import SwiftUI
import WebViewAMC

struct MainView: View {
    private let logger = Logger(logLevel: .error)
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @AppStorage("loggedCounter") private var loggedCounter: Int = 0
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var webViewHandler: WebViewHandler
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.requestReview,
        fallback: false
    ) private var requestReviewEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.maintenanceMode,
        fallback: false
    ) private var maintenanceMode

    var body: some View {
        if maintenanceMode {
            MaintenanceView()
        } else if isSetted {
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
                            logger.log(level: .error, message: "\(error)", source: "MainView")
                        }
                        if requestReviewEnabled,
                            loggedCounter > AppConstants.Thresholds.reviewRequestLoginCount {
                            Task {
                                try await Task.sleep(for: .seconds(AppConstants.Timing.reviewRequestDelay))
                                requestReview()
                            }
                        }
                    } else if newValue == false {
                        router.navigateBack()
                    }
                }
        } else {
            SchoolSelectionScreen()
                .onAppear {
                    WebViewManager.shared.webView.loadURL(id: "refresh", url: URLConstants.ipnBase)
                    webViewHandler.clearData()
                }
        }
    }
}
