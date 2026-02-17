import Foundation

@dynamicMemberLookup
struct ScheduleItem: Decodable, Sendable {
    var grupo: String
    var materia: String
    var profesores: String
    var lunes: String?
    var martes: String?
    var miercoles: String?
    var jueves: String?
    var viernes: String?
    var sabado: String?
    var edificio: String?
    var salon: String?

    subscript(dynamicMember member: String) -> String? {
        switch member {
        case "lunes": return lunes
        case "martes": return martes
        case "miercoles": return miercoles
        case "jueves": return jueves
        case "viernes": return viernes
        case "sabado": return sabado
        default: return nil
        }
    }
}
