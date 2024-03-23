import SwiftUI
import Routing

struct ScheduleView: View {
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let imageData = webViewMessageHandler.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                }
            }
            .onAppear {
                webViewManager.loadURL(url: saesURL + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
                Task {
                    await fetchPersonalData()
                }
                Task {
                    await fetchProfileImage()
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
    
    private func fetchPersonalData() async {
        await WebViewFetcher.shared.fetchData(execute: .personalData) {
            webViewMessageHandler.name.isEmpty
        }
    }
    
    private func fetchProfileImage() async {
        await WebViewFetcher.shared.fetchData(execute: .getProfileImage) {
            webViewMessageHandler.profileImageData.isEmptyOrNil
        }
    }
}
