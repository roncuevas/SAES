import SwiftUI
import Routing

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
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var selectedTab: LoggedTabs = .personalData
    private let webViewDataFetcher: WebViewDataFetcher = WebViewDataFetcher()
    
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
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
        .task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.webViewDataFetcher.fetchPersonalDataAndProfileImage() }
                group.addTask { await self.webViewDataFetcher.fetchSchedule() }
                group.addTask { await self.webViewDataFetcher.fetchGrades() }
                group.addTask { await self.webViewDataFetcher.fetchKardex() }
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            webViewManager.loadURL(url: .personalData)
            try? await Task.sleep(nanoseconds: 500_000_000)
            webViewManager.loadURL(url: .schedule)
            try? await Task.sleep(nanoseconds: 500_000_000)
            webViewManager.loadURL(url: .grades)
            try? await Task.sleep(nanoseconds: 500_000_000)
            webViewManager.loadURL(url: .kardex)
        }
    }
}
