import Foundation

enum LoggedTabs {
    case personalData
    case schedules
    case grades
    case kardex

    var value: String {
        switch self {
        case .personalData:
            return "Datos personales"
        case .schedules:
            return "Horario"
        case .grades:
            return "Calificaciones"
        case .kardex:
            return "Kardex"
        }
    }
}
