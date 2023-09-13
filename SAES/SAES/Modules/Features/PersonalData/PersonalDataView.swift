import SwiftUI
import WebKit

struct PersonalDataView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: LoginViewModel
    
    @AppStorage("boleta") var boleta = ""
    
    var body: some View {
        ScrollView {
            VStack {
                WebView(webView: $viewModel.webView, url: EndpointConstants.enmh + "/Alumnos/info_alumnos/Datos_Alumno.aspx")
                    .frame(height: 600)
                Text("Boleta: \(boleta)")
                    .onAppear {
                        print(navigationManager.path.count)
                        print(navigationManager.routesDebug)
                        viewModel.webView.evaluateJavaScript(JavaScriptConstants.common)
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
