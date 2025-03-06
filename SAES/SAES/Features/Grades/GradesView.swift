import SwiftUI
import Routing
import WebKit
import WebViewAMC

struct GradesView: View {
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    
    var body: some View {
        if !webViewMessageHandler.grades.isEmpty {
            VStack {
                List {
                    ForEach(webViewMessageHandler.gradesOrdered) { grupo in
                        Section(header: Text(grupo.nombre)) {
                            ForEach(grupo.materias) { materia in
                                MateriaRow(materia: materia)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calificaciones")
            .navigationBarBackButtonHidden()
            .webViewToolbar(webView: WebViewManager.shared.webView)
            .logoutToolbar(webViewManager: WebViewManager.shared)
            .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage, webViewManager: WebViewManager.shared)
        } else {
            NoContentView()
        }
    }
    
    struct MateriaRow: View {
        var materia: Materia
        @State private var isExpanded: Bool = false

        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack {
                    CalificacionRow(titulo: "1er Parcial", calificacion: materia.calificaciones.primerParcial)
                    CalificacionRow(titulo: "2o Parcial", calificacion: materia.calificaciones.segundoParcial)
                    CalificacionRow(titulo: "3er Parcial", calificacion: materia.calificaciones.tercerParcial)
                    CalificacionRow(titulo: "Ext", calificacion: materia.calificaciones.ext)
                    CalificacionRow(titulo: "Final", calificacion: materia.calificaciones.final)
                }
                .padding()
            } label: {
                Text(materia.nombre)
                    .font(.headline)
            }
        }
    }

    struct CalificacionRow: View {
        var titulo: String
        var calificacion: String

        var body: some View {
            HStack {
                Text(titulo)
                Spacer()
                Text(calificacion)
            }
            .padding(.vertical, 2)
        }
    }
}
