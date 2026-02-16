@preconcurrency import FirebaseRemoteConfig
import SwiftUI

@MainActor
struct LoggedView: View {
    @State private var selectedTab: LoggedTabs

    init() {
        let saved = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.defaultTab)
            ?? LoggedTabs.home.rawValue
        _selectedTab = State(initialValue: LoggedTabs(rawValue: saved) ?? .home)
    }
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.scheduleScreen,
        fallback: true
    ) private var scheduleScreenEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.kardexScreen,
        fallback: true
    ) private var kardexScreenEnabled

    var body: some View {
        TabView(selection: $selectedTab) {
            personalDataView
            if scheduleScreenEnabled {
                scheduleView
            }
            homeView
            gradesView
            if kardexScreenEnabled {
                kardexView
            }
        }
        .menuToolbar(elements: MenuConfiguration.logged.elements)
        .logoutToolbar()
        .navigationBarTitle(
            title: selectedTab.value,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: true
        )
        .toolbar(selectedTab == .kardex ? .hidden : .visible, for: .navigationBar)
        .onChange(of: selectedTab) { newValue in
            Task { await AnalyticsManager.shared.logScreen(newValue.rawValue) }
        }
    }

    private var personalDataView: some View {
        PersonalDataScreen()
            .tabItem {
                Label(Localization.personalData, systemImage: "person.fill")
            }
            .tag(LoggedTabs.personalData)
    }

    private var scheduleView: some View {
        ScheduleView()
            .tabItem {
                Label(Localization.schedule, systemImage: "calendar")
            }
            .tag(LoggedTabs.schedules)
    }

    private var homeView: some View {
        HomeScreen()
            .appErrorOverlay(isDataLoaded: true)
            .tabItem {
                Label(Localization.home, systemImage: "house.fill")
            }
            .tag(LoggedTabs.home)
    }

    private var gradesView: some View {
        GradesScreen()
            .tabItem {
                Label(Localization.grades, systemImage: "book.pages.fill")
            }
            .tag(LoggedTabs.grades)
    }

    private var kardexView: some View {
        KardexModelView()
            .tabItem {
                Label(
                    Localization.kardex,
                    systemImage: "list.bullet.clipboard.fill"
                )
            }
            .tag(LoggedTabs.kardex)
    }
}
