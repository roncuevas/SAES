@preconcurrency import FirebaseRemoteConfig
import NavigatorUI
import StoreKit
import SwiftUI
import WebViewAMC

@MainActor
struct MainView: View {
    private let logger = Logger(logLevel: .error)
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("isLogged") private var isLogged: Bool = false
    @AppStorage("loggedCounter") private var loggedCounter: Int = 0
    @Environment(\.requestReview) private var requestReview
    @Environment(\.navigator) private var navigator
    @EnvironmentObject private var webViewHandler: WebViewHandler
    @EnvironmentObject private var proxy: WebViewProxy
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.requestReview,
        fallback: false
    ) private var requestReviewEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.maintenanceMode,
        fallback: false
    ) private var maintenanceMode
    @State private var isOnLoggedScreen = false

    var body: some View {
        if maintenanceMode {
            MaintenanceView()
        } else if isSetted {
            LoginView()
                .alert(Localization.timeout, isPresented: $webViewHandler.isTimeout, actions: {
                    // TODO: Re-enable "Go Back" button once timeout false positives are resolved
                    // Button(Localization.goBack) {
                    //     webViewHandler.isTimeout = false
                    //     isSetted = false
                    // }
                    Button(Localization.refresh) {
                        webViewHandler.isTimeout = false
                        proxy.load(URLConstants.home.value, forceRefresh: true)
                    }
                }, message: {
                    Text(Localization.timeoutMessage)
                })
                .onChange(of: isLogged) { newValue in
                    if newValue, !isOnLoggedScreen {
                        loggedCounter += 1
                        navigator.push(AppDestination.logged)
                        isOnLoggedScreen = true
                        Task {
                            do {
                                try await AnalyticsManager.shared.sendData()
                            } catch {
                                logger.log(level: .error, message: "\(error)", source: "MainView")
                            }
                        }
                        if requestReviewEnabled,
                            loggedCounter > AppConstants.Thresholds.reviewRequestLoginCount {
                            Task {
                                try await Task.sleep(for: .seconds(AppConstants.Timing.reviewRequestDelay))
                                requestReview()
                            }
                        }
                    } else if newValue == false {
                        navigator.pop()
                        isOnLoggedScreen = false
                    }
                }
        } else {
            SchoolSelectionScreen()
                .onAppear {
                    proxy.load(URLConstants.ipnBase)
                    webViewHandler.clearData()
                }
        }
    }
}
