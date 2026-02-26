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

    private var minimumVersion: String {
        RemoteConfig.remoteConfig()
            .configValue(forKey: AppConstants.RemoteConfigKeys.minimumVersion)
            .stringValue ?? ""
    }

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    private var forceUpdateRequired: Bool {
        VersionComparer.isOlderThan(current: currentVersion, minimum: minimumVersion)
    }

    var body: some View {
        if forceUpdateRequired {
            ForceUpdateView(currentVersion: currentVersion, minimumVersion: minimumVersion)
        } else if maintenanceMode {
            MaintenanceView()
        } else if isSetted {
            LoginView()
                .task {
                    handleLoginState(isLogged)
                }
                .onChange(of: isLogged) { newValue in
                    handleLoginState(newValue)
                }
        } else {
            SchoolSelectionScreen()
                .onAppear {
                    proxy.load(URLConstants.ipnBase)
                    webViewHandler.clearData()
                }
        }
    }

    private func handleLoginState(_ isLoggedIn: Bool) {
        if isLoggedIn, !isOnLoggedScreen {
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
        } else if !isLoggedIn {
            guard webViewHandler.appError != .sessionExpired else { return }
            router.popNavigation()
            isOnLoggedScreen = false
        }
    }
}
