import AppRouter
import SwiftUI
import Toast

@MainActor
struct SettingsScreen: View {
    @AppStorage(AppConstants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = "dark"
    @AppStorage(AppConstants.UserDefaultsKeys.defaultTab) private var defaultTab: String = LoggedTabs.home.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.hapticFeedbackEnabled) private var hapticFeedbackEnabled: Bool = true
    @AppStorage(AppConstants.UserDefaultsKeys.showUpcomingEvents) private var showUpcomingEvents = true
    @AppStorage(AppConstants.UserDefaultsKeys.showNews) private var showNews = true
    @AppStorage(AppConstants.UserDefaultsKeys.showTodaySchedule) private var showTodaySchedule = true
    @AppStorage(AppConstants.UserDefaultsKeys.showScholarships) private var showScholarships = true
    @AppStorage(AppConstants.UserDefaultsKeys.showAnnouncements) private var showAnnouncements = true
    @EnvironmentObject private var webViewHandler: WebViewHandler
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var showMaintenancePreview = false
    @State private var showForceUpdatePreview = false
    @State private var showFeatureFlags = false
    @State private var showClearCookiesConfirmation = false
    @AppStorage(AppConstants.UserDefaultsKeys.debugSettingsEnabled) private var debugSettingsEnabled = false
    @AppStorage(AppConstants.UserDefaultsKeys.apiBaseURLOverride) private var apiBaseURLOverride: String = ""

    var body: some View {
        Form {
            appearanceSection
            generalSection
            homeSectionsSection
            aboutSection
            dataSection
            if debugSettingsEnabled {
                debugSection
                debugAPISection
            }
        }
        .task {
            await AnalyticsManager.shared.logScreen("settings")
        }
        .navigationBarTitle(
            title: Localization.settings,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: false
        )
        .fullScreenCover(isPresented: $showMaintenancePreview) {
            DebugNavigationWrapper {
                MaintenanceView()
                    .overlay(alignment: .topTrailing) {
                        dismissButton { showMaintenancePreview = false }
                    }
            }
        }
        .fullScreenCover(isPresented: $showForceUpdatePreview) {
            ForceUpdateView(minimumVersion: "1.6.0")
                .overlay(alignment: .topTrailing) {
                    dismissButton { showForceUpdatePreview = false }
                }
        }
        .sheet(isPresented: $showFeatureFlags) {
            FeatureFlagsSheet()
        }
        .confirmationDialog(
            Localization.debugClearCookies,
            isPresented: $showClearCookiesConfirmation,
            titleVisibility: .visible
        ) {
            Button(Localization.debugClearCookiesConfirm, role: .destructive) {
                Task {
                    await viewModel.clearCookies()
                    ToastManager.shared.toastToPresent = Toast(
                        icon: Image(systemName: "checkmark.circle"),
                        color: .green,
                        message: Localization.debugCookiesCleared
                    )
                }
            }
        } message: {
            Text(Localization.debugClearCookiesMessage)
        }
    }

    private var appearanceSection: some View {
        Section(Localization.appearance) {
            Picker(Localization.appearance, selection: $appearanceMode) {
                Text(Localization.system).tag("system")
                Text(Localization.light).tag("light")
                Text(Localization.dark).tag("dark")
            }
            .pickerStyle(.segmented)
        }
    }

    private var generalSection: some View {
        Section(Localization.general) {
            Picker(Localization.defaultTab, selection: $defaultTab) {
                Text(Localization.home).tag(LoggedTabs.home.rawValue)
                Text(Localization.grades).tag(LoggedTabs.grades.rawValue)
                Text(Localization.schedule).tag(LoggedTabs.schedules.rawValue)
                Text(Localization.personalData).tag(LoggedTabs.personalData.rawValue)
                Text(Localization.kardex).tag(LoggedTabs.kardex.rawValue)
            }
            Toggle(Localization.hapticFeedback, isOn: $hapticFeedbackEnabled)
        }
    }

    private var homeSectionsSection: some View {
        Section(Localization.homeSections) {
            Toggle(Localization.upcomingEvents, isOn: $showUpcomingEvents)
            Toggle(Localization.ipnNews, isOn: $showNews)
            Toggle(Localization.todaysSchedule, isOn: $showTodaySchedule)
            Toggle(Localization.announcements, isOn: $showAnnouncements)
            Toggle(Localization.becas, isOn: $showScholarships)
        }
    }

    private var aboutSection: some View {
        Section(Localization.about) {
            HStack {
                Text(Localization.version)
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var debugSection: some View {
        Section(Localization.debug) {
            Button {
                showMaintenancePreview = true
            } label: {
                Label(Localization.debugMaintenance, systemImage: "wrench.and.screwdriver.fill")
            }
            Button {
                showForceUpdatePreview = true
            } label: {
                Label(Localization.debugForceUpdate, systemImage: "arrow.down.to.line")
            }
            Button {
                UIPasteboard.general.string = AppDelegate.fcmToken()
                ToastManager.shared.toastToPresent = Toast(
                    icon: Image(systemName: "doc.on.doc"),
                    color: .green,
                    message: Localization.debugFCMTokenCopied
                )
            } label: {
                Label(Localization.debugCopyFCMToken, systemImage: "doc.on.doc")
            }
            Button {
                Task {
                    let token = await UserSessionManager.shared.cookiesString()
                    UIPasteboard.general.string = token
                    ToastManager.shared.toastToPresent = Toast(
                        icon: Image(systemName: "doc.on.doc"),
                        color: .green,
                        message: Localization.debugAuthTokenCopied
                    )
                }
            } label: {
                Label(Localization.debugCopyAuthToken, systemImage: "key")
            }
            Button {
                showFeatureFlags = true
            } label: {
                Label(Localization.debugFeatureFlags, systemImage: "flag")
            }
            Button(role: .destructive) {
                showClearCookiesConfirmation = true
            } label: {
                Label(Localization.debugClearCookies, systemImage: "trash")
            }
        }
    }

    private var debugAPISection: some View {
        Section(Localization.debugAPIBaseURL) {
            TextField(Localization.debugAPIBaseURLPlaceholder, text: $apiBaseURLOverride)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.URL)
            if !apiBaseURLOverride.isEmpty {
                Button {
                    apiBaseURLOverride = ""
                    ToastManager.shared.toastToPresent = Toast(
                        icon: Image(systemName: "checkmark.circle"),
                        color: .green,
                        message: Localization.debugAPIBaseURLRestored
                    )
                } label: {
                    Label(Localization.debugAPIBaseURLRestore, systemImage: "arrow.counterclockwise")
                }
            }
        }
    }

    private func dismissButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)
        }
        .padding()
    }

    private var dataSection: some View {
        Section {
            Button(Localization.resetConfiguration, role: .destructive) {
                showResetConfirmation = true
            }
            .confirmationDialog(
                Localization.resetConfiguration,
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button(Localization.reset, role: .destructive) {
                    viewModel.resetConfiguration(webViewHandler: webViewHandler, onComplete: { router.popToRoot() })
                }
            } message: {
                Text(Localization.resetConfigurationConfirmation)
            }

            Button(Localization.deleteAllData, role: .destructive) {
                showDeleteConfirmation = true
            }
            .confirmationDialog(
                Localization.deleteAllData,
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button(Localization.delete, role: .destructive) {
                    viewModel.deleteAllData(webViewHandler: webViewHandler, onComplete: { router.popToRoot() })
                }
            } message: {
                Text(Localization.deleteAllDataConfirmation)
            }
        }
    }
}

private struct DebugNavigationWrapper<Content: View>: View {
    @StateObject private var router = AppRouter()
    @ViewBuilder let content: () -> Content

    var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .navigationDestination(for: AppDestination.self) { $0.destinationView }
        }
        .environmentObject(router)
    }
}
