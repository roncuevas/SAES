import Foundation
import SwiftSoup

struct GradesParser: SAESParser {
    private static let selectors: ScrapingSelectorsConfiguration.GradesSelectors = {
        // swiftlint:disable:next force_try
        let config = try! ConfigurationLoader.shared.load(ScrapingSelectorsConfiguration.self, from: "scraping_selectors")
        return config.grades
    }()

    func parseGrades(_ data: Data) throws -> [Grupo] {
        let document = try convert(data)
        if try document.text().contains("evalues a tus PROFESORES") {
            throw GradesError.evaluateTeachers
        }

        let table: Element
        if let found = try Self.selectors.tableIDs.lazy.compactMap({ try document.getElementById($0) }).first {
            table = found
        } else {
            throw GradesError.noTableFound
        }

        // Obtener todas las filas de datos
        let rows = try table.select("tr").array()
        var grupos: [Grupo] = []

        // Loopear las filas (saltamos el encabezado)
        for row in rows[1...] {
            let cols = try row.select("td").array()
            guard cols.count >= Self.selectors.expectedColumnCount else { continue }

            let texts = try cols.map { try $0.text().trimmingCharacters(in: .whitespacesAndNewlines) }
            guard texts.count == Self.selectors.expectedColumnCount else { continue }
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

    func parseEvaluationLinks(_ data: Data) throws -> [EvaluationLink] {
        // 1. Convertir Data a String
        guard let htmlString = String(data: data, encoding: .utf8) else {
            return []
        }
        // 2. Parsear el HTML
        let document = try SwiftSoup.parse(htmlString)
        // 3. Obtener la tabla de evaluaciones
        let table: Element
        if let found = try Self.selectors.evaluationTableIDs.lazy.compactMap({ try document.getElementById($0) }).first {
            table = found
        } else {
            throw GradesError.noEvaluationTableFound
        }

        // 4. Seleccionar filas y omitir el encabezado
        let rows = try table.select("tr").array()
        var links: [EvaluationLink] = []

        for row in rows.dropFirst() {
            let cells = try row.select("td")
            guard cells.count >= 4 else { continue }

            // 5. Extraer datos de cada celda
            let group = try cells[0].text()
            let subject = try cells[1].text()
            let teacher = try cells[2].text()
            let href = try cells[3].select("a[href]").first()?.attr("href") ?? ""

            // 6. Crear el URL (ajusta base si es necesario)
            guard let url = URL(string: (URLConstants.evalTeachersBase.value + href)) else { continue }

            // 7. Agregar al arreglo de resultados
            links.append(EvaluationLink(group: group, subject: subject, teacher: teacher, url: url))
        }
        return links
    }
}

struct EvaluationLink {
    let group: String
    let subject: String
    let teacher: String
    let url: URL
}
