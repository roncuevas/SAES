import Routing
import SwiftUI
import WebViewAMC
import Inject

struct LoggedView: View {
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @State private var selectedTab: LoggedTabs = .personalData
    @State private var searchText: String = ""
    @ObserveInjection var forceRedraw

    var body: some View {
        TabView(selection: $selectedTab) {
            PersonalDataScreen()
                .tabItem {
                    Label(Localization.personalData, systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
            ScheduleView()
                .tabItem {
                    Label(Localization.schedule, systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
                .onAppear {
                    WebViewActions.shared.cancelOtherFetchs(id: "schedule")
                    WebViewActions.shared.schedule()
                }
            GradesView()
                .tabItem {
                    Label(Localization.grades, systemImage: "book.pages.fill")
                }
                .tag(LoggedTabs.grades)
                .onAppear {
                    WebViewActions.shared.cancelOtherFetchs(id: "grades")
                    WebViewActions.shared.grades()
                }
                .refreshable {
                    webViewMessageHandler.grades = []
                    WebViewActions.shared.grades()
                }
            KardexModelView(kardexModel: webViewMessageHandler.kardex.1, searchText: $searchText)
                .tabItem {
                    Label(Localization.kardex, systemImage: "list.bullet.clipboard.fill")
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
            NewsScreen()
                .tabItem {
                    Label(Localization.news, systemImage: "newspaper.fill")
                }
                .tag(LoggedTabs.news)
            IPNScheduleScreen()
                .tabItem {
                    Label(Localization.ipnSchedule, systemImage: "calendar.and.person")
                }
                .tag(LoggedTabs.ipnSchedule)
        }
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .if(selectedTab == .kardex) { view in
            view
                .toolbar(.hidden)
        }
        .if(selectedTab == .ipnSchedule) { view in
            view
                .navigationTitle("IPN Schedule")
                .toolbarBackground(.hidden, for: .tabBar)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarTitleDisplayMode(.automatic)
        }
        .onChange(of: selectedTab) { newValue in
            print(newValue)
        }
    }
}
