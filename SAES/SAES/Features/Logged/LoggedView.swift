import SwiftUI
import Routing
import WebViewAMC

enum LoggedTabs {
    case personalData
    case schedules
    case grades
    case kardex
    
    var value: String {
        switch self {
        case .personalData:
            return "Datos personales"
        case .schedules:
            return "Horario"
        case .grades:
            return "Calificaciones"
        case .kardex:
            return "Kardex"
        }
    }
}

struct LoggedView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var selectedTab: LoggedTabs = .personalData
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PersonalDataView()
                .tabItem {
                    Label("Datos personales",
                          systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
            ScheduleView()
                .tabItem {
                    Label("Horario", 
                          systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
            GradesView()
                .tabItem {
                    Label("Calificaciones",
                          systemImage: "book.pages.fill")
                }
                .tag(LoggedTabs.grades)
            KardexModelView(kardexModel: webViewMessageHandler.kardex.1)
                .tabItem {
                    Label("Kardex",
                          systemImage: "list.bullet.clipboard.fill")
                }
                .tag(LoggedTabs.kardex)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .onAppear {
            WebViewManager.shared.fetcher.fetchIterationsOrWhile(run: JScriptCode.personalData.value, description: "personalData") {
                webViewMessageHandler.name.isEmpty
            }
            WebViewManager.shared.fetcher.fetchIterationsOrWhile(run: JScriptCode.getProfileImage.value, description: "getProfileImage") {
                webViewMessageHandler.profileImageData.isEmptyOrNil
            }
            WebViewManager.shared.fetcher.fetchIterationsOrWhile(run: JScriptCode.schedule.value, description: "schedule") {
                webViewMessageHandler.schedule.isEmpty
            }
            WebViewManager.shared.fetcher.fetchIterationsOrWhile(run: JScriptCode.grades.value, description: "grades") {
                webViewMessageHandler.grades.isEmpty
            }
            WebViewManager.shared.fetcher.fetchIterationsOrWhile(run: JScriptCode.kardex.value, description: "kardex") {
                webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(url: URLConstants.personalData.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(url: URLConstants.schedule.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(url: URLConstants.grades.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(url: URLConstants.kardex.value)
        }
    }
}
