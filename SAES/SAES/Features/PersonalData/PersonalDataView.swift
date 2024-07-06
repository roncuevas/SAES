import SwiftUI
import Routing
import WebKit

struct PersonalDataView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @Binding var selectedTab: LoggedTabs
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    private let webViewDataFetcher: WebViewDataFetcher = WebViewDataFetcher()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                CSTextSelectable(header: "Nombre:", description: webViewMessageHandler.name)
                CSTextSelectable(header: "Boleta:", description: boleta)
                CSTextSelectable(header: "CURP:", description: webViewMessageHandler.curp)
                CSTextSelectable(header: "RFC:", description: webViewMessageHandler.rfc)
                CSTextSelectable(header: "Fecha de nacimiento:", description: webViewMessageHandler.birthday)
                CSTextSelectable(header: "Nacionalidad:", description: webViewMessageHandler.nationality)
                CSTextSelectable(header: "Lugar de nacimiento:", description: webViewMessageHandler.birthLocation)
            }
            .onAppear {
                guard selectedTab == .personalData else { return }
                webViewManager.loadURL(url: .personalData)
            }
            .task {
                guard selectedTab == .personalData else { return }
                await webViewDataFetcher.fetchPersonalDataAndProfileImage()
            }
        }
        .navigationTitle("Datos personales")
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
        .alert("Error cargando la apgina", isPresented: $webViewMessageHandler.isErrorPage) {
            Button("Ok") {
                webViewManager.loadURL(url: .base)
            }
        }
    }
    
    struct CSTextSelectable: View {
        let header: String
        let description: String
        let pasteboard = UIPasteboard.general
        
        var body: some View {
            HStack(spacing: 8) {
                Text(header)
                    .fontWeight(.bold)
                Text(description)
                    .textSelection(.enabled)
            }
            .onTapGesture {
                pasteboard.string = description
            }
        }
    }
}
