import SwiftUI
import Combine
import Routing
import WebKit
import WebViewAMC

struct GradesView: View {
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @State private var isRunningGrades: Bool = false
    
    var body: some View {
        content
            .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                isRunningGrades = tasks.contains { $0 == "grades" }
            }
    }
    
    @ViewBuilder
    private var content: some View {
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
            .navigationTitle(Localization.grades)
            .navigationBarBackButtonHidden()
            .webViewToolbar(webView: WebViewManager.shared.webView)
            .logoutToolbar(webViewManager: WebViewManager.shared)
            .errorLoadingAlert(isPresented: $webViewMessageHandler.isErrorPage, webViewManager: WebViewManager.shared)
        } else if isRunningGrades {
            SearchingView(title: Localization.searchingForGrades)
        } else {
            NoContentView {
                WebViewActions.shared.grades()
            }
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
