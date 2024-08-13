import SwiftUI

struct KardexModelView: View {
    let kardexModel: KardexModel?
    @State private var searchText = ""

    var body: some View {
        if let kardexModel {
            VStack {
                List {
                    Section(header: Text("Información del Estudiante")) {
                        Text("Carrera: \(kardexModel.carrera ?? "N/A")")
                        Text("Plan: \(kardexModel.plan ?? "N/A")")
                        Text("Promedio: \(kardexModel.promedio ?? "N/A")")
                    }
                    
                    if let kardexList = kardexModel.kardex {
                        Section("Calificaciones") {
                            ForEach(filteredKardexList(kardexList), id: \.semestre) { kardex in
                                KardexView(kardex: kardex)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Buscar materias")
            }
        } else {
            EmptyView()
        }
    }

    struct KardexView: View {
        let kardex: Kardex

        @State private var isExpanded = false

        var body: some View {
            DisclosureGroup(isExpanded: $isExpanded) {
                if let materias = kardex.materias {
                    ForEach(materias, id: \.clave) { materia in
                        MateriaKardexView(materiaKardex: materia)
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
        
        @State private var isExpanded = false

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
