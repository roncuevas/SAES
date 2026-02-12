import SwiftUI

struct SettingsScreen: View {
    @AppStorage(AppConstants.UserDefaultsKeys.appearanceMode) private var appearanceMode: String = "dark"
    @AppStorage(AppConstants.UserDefaultsKeys.defaultTab) private var defaultTab: String = LoggedTabs.home.rawValue
    @AppStorage(AppConstants.UserDefaultsKeys.hapticFeedbackEnabled) private var hapticFeedbackEnabled: Bool = true

    var body: some View {
        Form {
            appearanceSection
            generalSection
            aboutSection
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
}
