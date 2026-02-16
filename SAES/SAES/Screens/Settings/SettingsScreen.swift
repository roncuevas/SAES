import SwiftUI

@MainActor
struct SettingsScreen: View {
    @AppStorage(AppConstants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = "dark"
    @AppStorage(AppConstants.UserDefaultsKeys.defaultTab) private var defaultTab: String = LoggedTabs.home.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.hapticFeedbackEnabled) private var hapticFeedbackEnabled: Bool = true
    @EnvironmentObject private var webViewHandler: WebViewHandler
    @EnvironmentObject private var router: AppRouter
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        Form {
            appearanceSection
            generalSection
            aboutSection
            dataSection
        }
        .navigationBarTitle(
            title: Localization.settings,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: false
        )
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
