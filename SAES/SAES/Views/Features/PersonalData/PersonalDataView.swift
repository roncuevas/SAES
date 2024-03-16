import SwiftUI
import Routing
import WebKit

struct PersonalDataView: View {
    @AppStorage("saesURL") var saesURL: String = ""
    @AppStorage("boleta") var boleta: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject var webViewManager: WebViewManager
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        ScrollView {
            VStack {
                WebView(webView: $webViewManager.webView)
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
        .navigationTitle("Datos personales")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    webViewManager.executeJS(.logout)
                    isLogged = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        router.navigateBack()
                    }
                } label: {
                    Image(systemName: "door.right.hand.open")
                        .fontWeight(.bold)
                        .tint(.red)
                }
            }
        }
        // .navigationBarBackButtonHidden()
    }
}
