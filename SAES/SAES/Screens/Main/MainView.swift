@preconcurrency import FirebaseRemoteConfig
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
    @EnvironmentObject private var router: AppRouter
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
                .onChange(of: isLogged) { newValue in
                    if newValue, !isOnLoggedScreen {
                        loggedCounter += 1
                        router.navigateTo(.logged)
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
                        guard webViewHandler.appError != .sessionExpired else { return }
                        router.popNavigation()
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
