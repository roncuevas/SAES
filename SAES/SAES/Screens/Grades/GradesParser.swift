import Foundation
import SwiftSoup

struct GradesParser {
    func parseGrades(_ data: Data) throws -> [Grupo] {
        // Convertir a String y validar si pide evaluar profesores
        guard let html = String(data: data, encoding: .utf8) else {
            throw GradesError.dataParsingFailed
        }
        if html.contains("evalues a tus PROFESORES") {
            throw GradesError.evaluateTeachers
        }

        // Parsear HTML y localizar la tabla de calificaciones
        let doc = try SwiftSoup.parse(html)
        let table: Element
        if let element = try doc.getElementById("ctl00_mainCopy_GV_Calif") {
            table = element
        } else if let element = try doc.getElementById("mainCopy_GV_Calif") {
            table = element
        } else {
            throw GradesError.noTableFound
        }

        // Obtener todas las filas de datos
        let rows = try table.select("tr").array()
        var grupos: [Grupo] = []

        // Loopear las filas (saltamos el encabezado)
        for row in rows[1...] {
            let cols = try row.select("td").array()
            guard cols.count >= 7 else { continue }

            let texts = try cols.map { try $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
            guard texts.count == 7 else { continue }
            let grades = Calificacion(
                primerParcial: texts[2],
                segundoParcial: texts[3],
                tercerParcial: texts[4],
                ext: texts[5],
                final: texts[6]
            )
            let materia = Materia(id: texts[1], nombre: texts[1], calificaciones: grades)

            if let index = grupos.firstIndex(where: { $0.id == texts[0] }) {
                grupos[index].materias.append(materia)
            } else {
                grupos.append(Grupo(id: texts[0], nombre: texts[0], materias: [materia]))
            }
        }

        return grupos
    }
}
