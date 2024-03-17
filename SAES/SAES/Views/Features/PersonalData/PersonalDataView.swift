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
            VStack {
                Text("Boleta: \(boleta)")
                Text("Nombre: \(webViewMessageHandler.name)")
                Text("CURP: \(webViewMessageHandler.curp)")
            }
            .onAppear {
                webViewManager.loadURL(url: saesURL + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
            }
            .task {
                await fetchDataName()
                await fetchDataCURP()
            }
        }
        .navigationTitle("Datos personales")
        .navigationBarBackButtonHidden()
        .logoutToolbar(webViewManager: webViewManager)
        .webViewToolbar(webView: webViewManager.webView)
        .schoolSelectorToolbar()
    }
    
    private func fetchDataName() async {
        repeat {
            webViewManager.executeJS(.personalDataName)
            print("Fetching personal Name")
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                break
            }
        } while webViewMessageHandler.name.isEmpty
    }
    
    private func fetchDataCURP() async {
        repeat {
            webViewManager.executeJS(.personalDataCURP)
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                break
            }
        } while webViewMessageHandler.curp.isEmpty
    }
}
