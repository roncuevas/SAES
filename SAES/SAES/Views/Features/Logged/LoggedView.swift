import SwiftUI
import Routing

struct LoggedView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        TabView {
            PersonalDataView()
                .tabItem {
                    Label("Datos personales", systemImage: "person.fill")
                }
            PersonalDataView()
                .tabItem {
                    Label("Datos personales", systemImage: "person.fill")
                }
            PersonalDataView()
                .tabItem {
                    Label("Datos personales", systemImage: "person.fill")
                }
        }
        .navigationTitle("Datos personales")
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
    }
}
