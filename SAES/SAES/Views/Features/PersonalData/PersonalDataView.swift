import SwiftUI
import Routing
import WebKit

struct PersonalDataView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Boleta: \(boleta)")
                Text("Nombre: \(webViewMessageHandler.name)")
                Text("CURP: \(webViewMessageHandler.curp)")
                Text("RFC: \(webViewMessageHandler.rfc)")
            }
            .onAppear {
                webViewManager.loadURL(url: saesURL + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
            }
            .task {
                await fetchErrorPage()
                await fetchPersonalData()
            }
        }
        .navigationTitle("Datos personales")
        .navigationBarBackButtonHidden()
        .webViewToolbar(webView: webViewManager.webView)
        .logoutToolbar(webViewManager: webViewManager)
        .alert("Error cargando la apgina", isPresented: $webViewMessageHandler.isErrorPage) {
            Button("Ok") {
                webViewManager.loadURL(url: saesURL)
            }
        }
    }
    
    private func fetchPersonalData() async {
        repeat {
            webViewManager.executeJS(.personalData)
            debugPrint("Fetching personal Name")
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                break
            }
        } while webViewMessageHandler.name.isEmpty
    }
    
    private func fetchErrorPage() async {
        repeat {
            webViewManager.executeJS(.isErrorPage)
            debugPrint("Fetching errors")
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                break
            }
        } while webViewMessageHandler.name.isEmpty
    }
}
