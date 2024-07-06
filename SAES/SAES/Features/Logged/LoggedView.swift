import SwiftUI
import Routing

enum LoggedTabs {
    case personalData
    case schedules
    case grades
    
    var value: String {
        switch self {
        case .personalData:
            return "Datos personales"
        case .schedules:
            return "Horario"
        case .grades:
            return "Calificaciones"
        }
    }
}

struct LoggedView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var selectedTab: LoggedTabs = .personalData
    
    var body: some View {
        TabView(selection: $selectedTab) {
            PersonalDataView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Datos personales",
                          systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
            ScheduleView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Horario", 
                          systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
            GradesView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Calificaciones",
                          systemImage: "book.pages.fill")
                }
                .tag(LoggedTabs.grades)
        }
        .onChange(of: selectedTab) { newValue in
            switch newValue {
            case .personalData:
                webViewManager.loadURL(url: .personalData)
            case .schedules:
                webViewManager.loadURL(url: .schedule)
            case .grades:
                webViewManager.loadURL(url: .grades)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
    }
}
