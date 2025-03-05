import Routing
import SwiftUI
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
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var selectedTab: LoggedTabs = .personalData

    var body: some View {
        TabView(selection: $selectedTab) {
            PersonalDataView()
                .tabItem {
                    Label(
                        "Datos personales",
                        systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
            ScheduleView()
                .tabItem {
                    Label(
                        "Horario",
                        systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
            GradesView()
                .tabItem {
                    Label(
                        "Calificaciones",
                        systemImage: "book.pages.fill")
                }
                .tag(LoggedTabs.grades)
            KardexModelView(kardexModel: webViewMessageHandler.kardex.1)
                .tabItem {
                    Label(
                        "Kardex",
                        systemImage: "list.bullet.clipboard.fill")
                }
                .tag(LoggedTabs.kardex)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .task {
            WebViewManager.shared.fetcher.fetch([
                DataFetchRequest(id: "personalData",
                                 url: URLConstants.personalData.value,
                                 javaScript: JScriptCode.personalData.value,
                                 iterations: 15,
                                 condition: { webViewMessageHandler.name.isEmpty }),
                DataFetchRequest(id: "getProfileImage",
                                 javaScript: JScriptCode.getProfileImage.value,
                                 iterations: 15,
                                 condition: { webViewMessageHandler.profileImageData.isEmptyOrNil }),
                DataFetchRequest(id: "schedule",
                                 url: URLConstants.schedule.value,
                                 javaScript: JScriptCode.schedule.value,
                                 iterations: 15,
                                 condition: { webViewMessageHandler.schedule.isEmpty }),
                DataFetchRequest(id: "grades",
                                 url: URLConstants.grades.value,
                                 javaScript: JScriptCode.grades.value,
                                 iterations: 15,
                                 condition: { webViewMessageHandler.grades.isEmpty }),
                DataFetchRequest(id: "kardex",
                                 url: URLConstants.kardex.value,
                                 javaScript: JScriptCode.kardex.value,
                                 iterations: 15,
                                 condition: { webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true })
            ])
        }
        /*
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(
                url: URLConstants.personalData.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(
                url: URLConstants.schedule.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(
                url: URLConstants.grades.value)
            try? await Task.sleep(nanoseconds: 500_000_000)
            WebViewManager.shared.webView.loadURL(
                url: URLConstants.kardex.value)
        }
         */
    }
}
