import Foundation

struct GradeItem: Codable {
    var gpo: String
    var materia: String
    var primerParcial: String
    var segundoParcial: String
    var tercerParcial: String
    var ext: String
    var final: String
    
    enum CodingKeys: String, CodingKey {
        case gpo
        case materia
        case primerParcial = "1er_parcial"
        case segundoParcial = "2o_parcial"
        case tercerParcial = "3er_parcial"
        case ext
        case final
    }
}

struct Calificacion: Codable, Identifiable {
    var id = UUID()
    var primerParcial: String
    var segundoParcial: String
    var tercerParcial: String
    var ext: String
    var final: String
}

struct Materia: Codable, Identifiable {
    var id = UUID()
    var nombre: String
    var calificaciones: Calificacion
}

struct Grupo: Codable, Identifiable {
    var id = UUID()
    var nombre: String
    var materias: [Materia]
}
