import Routing
import SwiftUI
import WebViewAMC
import Inject

struct LoggedView: View {
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var selectedTab: LoggedTabs = .personalData
    @State private var searchText: String = ""
    @ObserveInjection var forceRedraw

    var body: some View {
        TabView(selection: $selectedTab) {
            PersonalDataView()
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
                    WebViewActions.shared.cancelOtherFetchs()
                    WebViewActions.shared.schedule()
                }
            GradesView()
                .tabItem {
                    Label(Localization.grades, systemImage: "book.pages.fill")
                }
                .tag(LoggedTabs.grades)
                .onAppear {
                    WebViewActions.shared.cancelOtherFetchs()
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
                    WebViewActions.shared.cancelOtherFetchs()
                    WebViewActions.shared.kardex()
                }
                .refreshable {
                    webViewMessageHandler.kardex.1 = nil
                    WebViewActions.shared.kardex()
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .if(selectedTab == .kardex) { view in
            view
                .toolbar(.hidden)
        }
    }
}
