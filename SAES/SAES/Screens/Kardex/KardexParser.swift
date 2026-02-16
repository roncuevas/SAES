import Foundation
import SwiftSoup

struct KardexParser: SAESParser {
    private static let selectors: ScrapingSelectorsConfiguration.KardexSelectors = {
        // swiftlint:disable:next force_try
        let config = try! ConfigurationLoader.shared.load(
            ScrapingSelectorsConfiguration.self, from: "scraping_selectors"
        )
        return config.kardex
    }()

    func parseKardex(_ data: Data) throws -> KardexModel {
        let document = try convert(data)

        guard let panel = try Self.selectors.panelIDs
            .lazy.compactMap({ try? document.getElementById($0) }).first
        else { throw KardexError.noPanelFound }

        let carrera = try? Self.selectors.carreraIDs
            .lazy.compactMap({ try? document.getElementById($0) }).first?
            .text().trimmingCharacters(in: .whitespacesAndNewlines)

        let plan = try? Self.selectors.planIDs
            .lazy.compactMap({ try? document.getElementById($0) }).first?
            .text().trimmingCharacters(in: .whitespacesAndNewlines)

        let promedio = try? Self.selectors.promedioIDs
            .lazy.compactMap({ try? document.getElementById($0) }).first?
            .text().trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        let tables = try panel.select(Self.selectors.semesterTablesSelector).array()
        let kardexList: [Kardex] = try tables.map { table in
            let allRows = try table.select("tr").array()
            guard let firstRow = allRows.first else {
                return Kardex(semestre: nil, materias: nil)
            }
            let semestre = try firstRow.select("td").first()?
                .text().trimmingCharacters(in: .whitespacesAndNewlines)

            let dataRows = allRows.dropFirst(2)
            let materias: [MateriaKardex] = try dataRows.map { row in
                let cells = try row.select("td").array().map {
                    try $0.text().trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return MateriaKardex(
                    clave: cells.indices.contains(0) ? cells[0] : nil,
                    materia: cells.indices.contains(1) ? cells[1] : nil,
                    fecha: cells.indices.contains(2) ? cells[2] : nil,
                    periodo: cells.indices.contains(3) ? cells[3] : nil,
                    formaEval: cells.indices.contains(4) ? cells[4] : nil,
                    calificacion: cells.indices.contains(5) ? cells[5] : nil
                )
            }
            return Kardex(semestre: semestre, materias: materias)
        }

        return KardexModel(carrera: carrera, plan: plan, promedio: promedio, kardex: kardexList)
    }
}
