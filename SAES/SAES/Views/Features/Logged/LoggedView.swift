import SwiftUI
import Routing

enum LoggedTabs {
    case personalData
    case schedules
    
    var value: String {
        switch self {
        case .personalData:
            return LoggedView.Constants.personalData
        case .schedules:
            return LoggedView.Constants.schedules
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
                    Label(Constants.personalData, systemImage: "person.fill")
                }
                .tag(LoggedTabs.personalData)
            ScheduleView(selectedTab: $selectedTab)
                .tabItem {
                    Label(Constants.schedules, systemImage: "calendar")
                }
                .tag(LoggedTabs.schedules)
        }
        .onChange(of: selectedTab) { newValue in
            switch newValue {
            case .personalData:
                webViewManager.loadURL(url: .personalData)
            case .schedules:
                webViewManager.loadURL(url: .schedule)
            }
        }
        .navigationTitle(selectedTab.value)
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
    }
    
    struct Constants {
        static let personalData: String = NSLocalizedString("Datos personales", comment: "")
        static let schedules: String = NSLocalizedString("Horario", comment: "")
    }
}
