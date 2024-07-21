import SwiftUI

// MARK: - MateriaKardexView
struct MateriaKardexView: View {
    let materiaKardex: MateriaKardex

    var body: some View {
        VStack(alignment: .leading) {
            Text("Clave: \(materiaKardex.clave ?? "N/A")")
            Text("Materia: \(materiaKardex.materia ?? "N/A")")
            Text("Fecha: \(materiaKardex.fecha ?? "N/A")")
            Text("Periodo: \(materiaKardex.periodo ?? "N/A")")
            Text("Forma Eval: \(materiaKardex.formaEval ?? "N/A")")
            Text("Calificación: \(materiaKardex.calificacion ?? "N/A")")
        }
        .padding()
    }
}

// MARK: - KardexView
struct KardexView: View {
    let kardex: Kardex

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            if let materias = kardex.materias {
                ForEach(materias, id: \.clave) { materia in
                    MateriaKardexView(materiaKardex: materia)
                        .padding(.leading, 20)
                }
            }
        } label: {
            Text("Semestre: \(kardex.semestre ?? "N/A")")
                .font(.headline)
        }
        .padding()
    }
}

// MARK: - KardexModelView
struct KardexModelView: View {
    let kardexModel: KardexModel?
    @State private var searchText = ""

    var body: some View {
        if let kardexModel {
            List {
                Section(header: Text("Información del Estudiante")) {
                    Text("Escuela: \(kardexModel.escuela ?? "N/A")")
                    Text("Boleta: \(kardexModel.boleta ?? "N/A")")
                    Text("Nombre: \(kardexModel.nombre ?? "N/A")")
                    Text("Carrera: \(kardexModel.carrera ?? "N/A")")
                    Text("Plan: \(kardexModel.plan ?? "N/A")")
                    Text("Promedio: \(kardexModel.promedio ?? "N/A")")
                }
                
                if let kardexList = kardexModel.kardex {
                    ForEach(filteredKardexList(kardexList), id: \.semestre) { kardex in
                        KardexView(kardex: kardex)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .searchable(text: $searchText, prompt: "Buscar materias")
        } else {
            EmptyView()
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
