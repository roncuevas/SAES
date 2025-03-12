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
        .onAppear {
            WebViewActions.shared.cancelOtherFetchs()
            WebViewActions.shared.personalData()
            WebViewActions.shared.getProfileImage()
        }
        .refreshable {
            webViewMessageHandler.personalData.clearPersonalData()
            WebViewActions.shared.personalData()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if webViewMessageHandler.personalData.hasPersonalData {
            List {
                /*
                Section("Fotografia") {
                    CSTextSelectable(header: "Foto",
                                     description: "Foto",
                                     image: webViewMessageHandler.profileImage)
                }
                 */
                Section("Datos generales") {
                    CSTextSelectable(header: "Nombre", description: webViewMessageHandler.personalData["name"], image: webViewMessageHandler.profileImage)
                    CSTextSelectable(header: "Boleta", description: webViewMessageHandler.personalData["studentID"])
                    CSTextSelectable(header: "Campus", description: webViewMessageHandler.personalData["campus"])
                    CSTextSelectable(header: "CURP", description: webViewMessageHandler.personalData["curp"])
                    CSTextSelectable(header: "RFC", description: webViewMessageHandler.personalData["rfc"])
                    CSTextSelectable(header: "Cartilla", description: webViewMessageHandler.personalData["militaryID"])
                    CSTextSelectable(header: "Pasaporte", description: webViewMessageHandler.personalData["passport"])
                    CSTextSelectable(header: "Sexo", description: webViewMessageHandler.personalData["gender"])
                }
                Section("Nacimiento") {
                    CSTextSelectable(header: "Fecha de nacimiento", description: webViewMessageHandler.personalData["birthday"])
                    CSTextSelectable(header: "Nacionalidad", description: webViewMessageHandler.personalData["nationality"])
                    CSTextSelectable(header: "Lugar de nacimiento", description: webViewMessageHandler.personalData["birthPlace"])
                }
                Section("Direccion") {
                    CSTextSelectable(header: "Calle", description: webViewMessageHandler.personalData["street"])
                    CSTextSelectable(header: "Numero", description: webViewMessageHandler.personalData["extNumber"])
                    CSTextSelectable(header: "Numero interior", description: webViewMessageHandler.personalData["intNumber"])
                    CSTextSelectable(header: "Colonia", description: webViewMessageHandler.personalData["neighborhood"])
                    CSTextSelectable(header: "Codigo Postal", description: webViewMessageHandler.personalData["zipCode"])
                    CSTextSelectable(header: "Estado", description: webViewMessageHandler.personalData["state"])
                    CSTextSelectable(header: "Municipio", description: webViewMessageHandler.personalData["municipality"])
                    CSTextSelectable(header: "Telefono", description: webViewMessageHandler.personalData["phone"])
                    CSTextSelectable(header: "Celular", description: webViewMessageHandler.personalData["mobile"])
                    CSTextSelectable(header: "Correo", description: webViewMessageHandler.personalData["email"])
                    CSTextSelectable(header: "Trabajando", description: webViewMessageHandler.personalData["working"])
                    CSTextSelectable(header: "Telefono de la oficina", description: webViewMessageHandler.personalData["officePhone"])
                }
                Section("Escolaridad") {
                    CSTextSelectable(header: "Escuela de procedencia", description: webViewMessageHandler.personalData["schoolOrigin"])
                    CSTextSelectable(header: "Ubicacion de escuela de procedencia", description: webViewMessageHandler.personalData["schoolOriginLocation"])
                    CSTextSelectable(header: "Promedio de secundaria", description: webViewMessageHandler.personalData["gpaMiddleSchool"])
                    CSTextSelectable(header: "Promedio de nivel medio superior", description: webViewMessageHandler.personalData["gpaHighSchool"])
                }
                Section("Padre/Tutor") {
                    CSTextSelectable(header: "Nombre del tutor", description: webViewMessageHandler.personalData["guardianName"])
                    CSTextSelectable(header: "RFC del tutor", description: webViewMessageHandler.personalData["guardianRFC"])
                    CSTextSelectable(header: "Nombre del padre", description: webViewMessageHandler.personalData["fathersName"])
                    CSTextSelectable(header: "Nombre de la madre", description: webViewMessageHandler.personalData["mothersName"])
                }
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
        var description: String?
        var image: UIImage?
        let pasteboard = UIPasteboard.general
        
        var body: some View {
            if let description, !description.replacingOccurrences(of: " ", with: "").isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(header)
                        .fontWeight(.bold)
                    Text(description)
                        .textSelection(.enabled)
                    if let image = image {
                        HStack {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(Circle())
                                .frame(width: 100)
                            Spacer()
                        }
                    }
                }
                .onTapGesture {
                    pasteboard.string = description
                }
            }
        }
    }
}
