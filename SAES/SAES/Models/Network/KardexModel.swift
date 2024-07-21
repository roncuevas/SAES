import Foundation

// MARK: - KardexModel
struct KardexModel: Codable {
    let carrera, plan, promedio: String?
    let kardex: [Kardex]?
}

// MARK: - Kardex
struct Kardex: Codable {
    let semestre: String?
    let materias: [MateriaKardex]?
}

// MARK: - Materia
struct MateriaKardex: Codable {
    let clave, materia, fecha, periodo: String?
    let formaEval: String?
    let calificacion: String?

    enum CodingKeys: String, CodingKey {
        case clave, materia, fecha, periodo
        case formaEval = "forma_eval"
        case calificacion
    }
}
