import SwiftUI
import Routing

struct ScheduleView: View {
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
                ForEach(webViewMessageHandler.schedule, id: \.materia) { materia in
                    Text(materia.materia)
                    Text(materia.profesores)
                    Text(materia.lunes.debugDescription)
                    Text(materia.martes.debugDescription)
                    Text(materia.miercoles.debugDescription)
                    Text(materia.jueves.debugDescription)
                    Text(materia.viernes.debugDescription)
                    Text(materia.sabado.debugDescription)
                }
            }
            .task {
                guard selectedTab == .schedules else { return }
                webViewManager.loadURL(url: saesURL + "/Alumnos/Informacion_semestral/Horario_Alumno.aspx")
                await webViewDataFetcher.fetchSchedule()
            }
        }
        .alert("Error cargando la pagina", isPresented: $webViewMessageHandler.isErrorPage) {
            Button("Ok") {
                webViewManager.loadURL(url: saesURL)
            }
        }
    }
}
