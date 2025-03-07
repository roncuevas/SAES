import SwiftUI
import Routing
import WebKit
import WebViewAMC

struct PersonalDataView: View {
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var isRunningPersonalData: Bool = false
    
    var body: some View {
        content
            .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                self.isRunningPersonalData = tasks.contains { $0 == "personalData" }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if !webViewMessageHandler.name.isEmpty {
            List {
                CSTextSelectable(header: "Nombre", description: webViewMessageHandler.name)
                CSTextSelectable(header: "Boleta", description: boleta)
                CSTextSelectable(header: "CURP", description: webViewMessageHandler.curp)
                CSTextSelectable(header: "RFC", description: webViewMessageHandler.rfc)
                CSTextSelectable(header: "Fecha de nacimiento", description: webViewMessageHandler.birthday)
                CSTextSelectable(header: "Nacionalidad", description: webViewMessageHandler.nationality)
                CSTextSelectable(header: "Lugar de nacimiento", description: webViewMessageHandler.birthLocation)
            }
            .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage, webViewManager: WebViewManager.shared)
        } else if isRunningPersonalData {
            SearchingView(title: "Buscando datos personales...")
        } else {
            NoContentView {
                WebViewActions.shared.personalData()
            }
        }
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
