import SwiftUI
import WebKit

struct PersonalDataView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var webViewManager: WebViewManager
    
    @AppStorage("saesURL") var saesURL: String = ""
    @AppStorage("boleta") var boleta: String = ""
    
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
                        print(navigationManager.path.count)
                        print(navigationManager.routesDebug)
                        webViewManager.webView.evaluateJavaScript(JavaScriptConstants.common)
                    }
            }
        }
    }
}

struct PersonalDataView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalDataView()
    }
}
