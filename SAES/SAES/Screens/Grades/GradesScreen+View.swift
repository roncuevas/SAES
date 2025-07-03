import SwiftUI
import Combine
import CustomKit
import Routing
import WebKit
import WebViewAMC

extension GradesScreen: View {
    var body: some View {
        content
            .task {
                await viewModel.getGrades()
            }
            .refreshable {
                await viewModel.getGrades()
            }
            .loadingScreen(isLoading: $isLoadingScreen)
    }

    @ViewBuilder
    private var content: some View {
        if !viewModel.grades.isEmpty {
            VStack {
                List {
                    ForEach(viewModel.grades) { grupo in
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
        } else if viewModel.evaluateTeacher {
            NoContentView(
                title: Localization.needEvaluateTeachers,
                description: Localization.youCanEvaluate,
                firstButtonTitle: Localization.evaluateAutomatically,
                icon: Image(systemName: "person.fill.checkmark.and.xmark")
            ) {
                isPresentingAlert.toggle()
            }
            .alert(
                Localization.evaluateAutomatically,
                isPresented: $isPresentingAlert) {
                    Button(Localization.evaluate) {
                        Task {
                            isLoadingScreen = true
                            await viewModel.evaluateTeachers()
                            await viewModel.getGrades()
                            isLoadingScreen = false
                        }
                    }
                    Button(Localization.cancel) {
                        isPresentingAlert.toggle()
                    }
                } message: {
                    Text(Localization.thisWillRateTeachers)
                }

        } else if isRunningGrades {
            SearchingView(title: Localization.searchingForGrades)
        } else {
            NoContentView {
                Task {
                    await viewModel.getGrades()
                }
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
