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
            VStack(alignment: .leading) {
                Text("Boleta: \(boleta)")
                Text("Nombre: \(webViewMessageHandler.name)")
                    .textSelection(.enabled)
                Text("CURP: \(webViewMessageHandler.curp)")
                Text("RFC: \(webViewMessageHandler.rfc)")
                Text("Cumpleanos: \(webViewMessageHandler.birthday)")
                Text("Nacionalidad: \(webViewMessageHandler.nationality)")
                Text("Lugar de nacimiento: \(webViewMessageHandler.birthLocation)")
                if let imageData = webViewMessageHandler.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                }
            }
            .onAppear {
                guard selectedTab == .personalData else { return }
                webViewManager.loadURL(url: saesURL + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
                Task {
                    await webViewDataFetcher.fetchPersonalDataAndProfileImage()
                }
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
}
