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
                    Label("Inicio", systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
                .onAppear {
                    WebViewActions.shared.cancelOtherFetchs()
                    WebViewActions.shared.personalData()
                }
                .refreshable {
                    webViewMessageHandler.name = ""
                    WebViewActions.shared.personalData()
                }
            ScheduleView()
                .tabItem {
                    Label("Horario", systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
                .onAppear {
                    WebViewActions.shared.cancelOtherFetchs()
                    WebViewActions.shared.schedule()
                }
            GradesView()
                .tabItem {
                    Label("Calificaciones", systemImage: "book.pages.fill")
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
                    Label("Kardex", systemImage: "list.bullet.clipboard.fill")
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
