import SwiftUI
import Routing
import WebKit
import WebViewAMC

struct PersonalDataView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        List {
            CSTextSelectable(header: "Nombre", description: webViewMessageHandler.name)
            CSTextSelectable(header: "Boleta", description: boleta)
            CSTextSelectable(header: "CURP", description: webViewMessageHandler.curp)
            CSTextSelectable(header: "RFC", description: webViewMessageHandler.rfc)
            CSTextSelectable(header: "Fecha de nacimiento", description: webViewMessageHandler.birthday)
            CSTextSelectable(header: "Nacionalidad", description: webViewMessageHandler.nationality)
            CSTextSelectable(header: "Lugar de nacimiento", description: webViewMessageHandler.birthLocation)
        }
        .navigationTitle("Datos personales")
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .logoutToolbar(webViewManager: WebViewManager.shared)
        .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage, webViewManager: WebViewManager.shared)
    }
    
    struct CSTextSelectable: View {
        let header: String
        let description: String
        let pasteboard = UIPasteboard.general
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
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
