import SwiftUI
import Routing
import WebKit

struct PersonalDataView: View {
    @AppStorage("saesURL") var saesURL: String = ""
    @AppStorage("boleta") var boleta: String = ""
    @EnvironmentObject var webViewManager: WebViewManager
    @StateObject private var router: Router<NavigationRoute> = .init()
    
    var body: some View {
        ScrollView {
            VStack {
                WebView(webView: $webViewManager    .webView)
                    .onAppear {
                        webViewManager.loadURL(url: saesURL + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
                    }
                    .frame(height: 600)
                Text("Boleta: \(boleta)")
                    .onAppear {
                        webViewManager.webView.evaluateJavaScript(JavaScriptConstants.common)
                    }
            }
        }
    }
}
