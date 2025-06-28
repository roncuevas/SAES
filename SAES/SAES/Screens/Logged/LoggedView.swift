import Routing
import SwiftUI
import WebViewAMC

struct LoggedView: View {
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @State private var selectedTab: LoggedTabs = .home
    @State private var searchText: String = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            personalDataView
            scheduleView
            homeView
            gradesView
            kardexView
        }
        .menuToolbar(elements: [
            .news, .ipnSchedule, .debug, .feedback, .logout
        ])
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .navigationBarTitle(
            title: selectedTab.value,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: true
        )
        .if(selectedTab == .kardex) { view in
            view
                .toolbar(.hidden, for: .navigationBar)
        }
        .onChange(of: selectedTab) { newValue in
            AnalyticsManager.shared.logScreen(newValue.rawValue)
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
            .onAppear {
                WebViewActions.shared.cancelOtherFetchs(id: "schedule")
                WebViewActions.shared.schedule()
            }
    }

    private var homeView: some View {
        NavigationView {
            HomeScreen()
        }
        .tabItem {
            Label(Localization.home, systemImage: "house.fill")
        }
        .tag(LoggedTabs.home)
    }

    private var gradesView: some View {
        GradesView()
            .tabItem {
                Label(Localization.grades, systemImage: "book.pages.fill")
            }
            .tag(LoggedTabs.grades)
    }

    private var kardexView: some View {
        NavigationView {
            KardexModelView(
                kardexModel: webViewMessageHandler.kardex.1,
                searchText: $searchText
            )
            .menuToolbar(elements: [
                .news, .ipnSchedule, .debug, .feedback, .logout
            ])
            .logoutToolbar(webViewManager: WebViewManager.shared)
            .navigationBarTitle(
                title: selectedTab.value,
                titleDisplayMode: .inline,
                background: .visible,
                backButtonHidden: true
            )
        }
        .searchable(
            text: $searchText,
            placement: .toolbar,
            prompt: Localization.prompt
        )
        .tabItem {
            Label(
                Localization.kardex,
                systemImage: "list.bullet.clipboard.fill"
            )
        }
        .tag(LoggedTabs.kardex)
        .onAppear {
            WebViewActions.shared.cancelOtherFetchs(id: "kardex")
            WebViewActions.shared.kardex()
        }
        .refreshable {
            webViewMessageHandler.kardex.1 = nil
            WebViewActions.shared.kardex()
        }
    }
}
