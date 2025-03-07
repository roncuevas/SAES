import SwiftUI
import Inject
import WebViewAMC

struct KardexModelView: View {
    let kardexModel: KardexModel?
    @Binding var searchText: String
    @ObserveInjection var forceRedraw
    @State private var isRunningKardex: Bool = false

    var body: some View {
        NavigationView {
            content
                .searchable(text: $searchText, prompt: "Buscar por materia")
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Kardex")
                .webViewToolbar(webView: WebViewManager.shared.webView)
                .logoutToolbar(webViewManager: WebViewManager.shared)
                .refreshable { WebViewActions.shared.kardex() }
                .onReceive(WebViewManager.shared.fetcher.tasksRunning) { tasks in
                    self.isRunningKardex = tasks.contains { $0 == "kardex" }
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let kardexModel {
            List {
                Section(header: Text("Información del Estudiante")) {
                    Text("Carrera: \(kardexModel.carrera ?? "N/A")")
                    Text("Plan: \(kardexModel.plan ?? "N/A")")
                    Text("Promedio: \(kardexModel.promedio ?? "N/A")")
                }
                
                if let kardexList = kardexModel.kardex {
                    Section("Calificaciones") {
                        ForEach(filteredKardexList(kardexList), id: \.semestre) { kardex in
                            if kardex.materias?.count ?? 0 > 0 {
                                if !searchText.isEmpty {
                                    KardexView(kardex: kardex, isExpanded: true)
                                } else {
                                    KardexView(kardex: kardex)
                                }
                            }
                        }
                    }
                }
            }
        } else if isRunningKardex {
            SearchingView()
        } else {
            NoContentView {
                WebViewActions.shared.kardex()
            }
        }
    }

    struct KardexView: View {
        let kardex: Kardex
        @State private var isExpanded: Bool
        
        init(kardex: Kardex, isExpanded: Bool = false) {
            self.kardex = kardex
            self.isExpanded = isExpanded
        }

        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let materias = kardex.materias {
                    ForEach(materias, id: \.clave) { materia in
                        MateriaKardexView(materiaKardex: materia, isExpanded: isExpanded)
                            .padding(.leading, 16)
                    }
                }
            } label: {
                Text("\(kardex.semestre ?? "N/A")")
                    .font(.headline)
            }
        }
    }
    
    struct MateriaKardexView: View {
        let materiaKardex: MateriaKardex
        @State private var isExpanded: Bool
        
        init(materiaKardex: MateriaKardex, isExpanded: Bool) {
            self.materiaKardex = materiaKardex
            self.isExpanded = isExpanded
        }

        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                VStack(alignment: .leading) {
                    Text("Clave: \(materiaKardex.clave ?? "N/A")")
                    Text("Materia: \(materiaKardex.materia ?? "N/A")")
                    Text("Fecha: \(materiaKardex.fecha ?? "N/A")")
                    Text("Periodo: \(materiaKardex.periodo ?? "N/A")")
                    Text("Forma Eval: \(materiaKardex.formaEval ?? "N/A")")
                    Text("Calificación: \(materiaKardex.calificacion ?? "N/A")")
                }
            } label: {
                Text("\(materiaKardex.materia ?? "N/A")")
                    .font(.subheadline)
            }
        }
    }
    
    func filteredKardexList(_ kardexList: [Kardex]) -> [Kardex] {
        if searchText.isEmpty {
            return kardexList
        } else {
            return kardexList.map { kardex in
                let filteredMaterias = kardex.materias?.filter { materia in
                    materia.materia?.localizedCaseInsensitiveContains(searchText) ?? false
                }
                return Kardex(semestre: kardex.semestre, materias: filteredMaterias)
            }
        }
    }
}
