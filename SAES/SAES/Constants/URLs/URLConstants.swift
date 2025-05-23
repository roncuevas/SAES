import Foundation

enum URLConstants {
    case base
    case standard
    case home
    case personalData
    case schedule
    case grades
    case kardex
    case personalPhoto
    case academic

    var baseURL: String {
        UserDefaults.standard.string(forKey: "saesURL") ?? ""
    }

    var value: String {
        switch self {
        case .base:
            baseURL
        case .standard:
            baseURL + "default.aspx"
        case .home:
            baseURL + "Alumnos/default.aspx"
        case .personalData:
            baseURL + "Alumnos/info_alumnos/Datos_Alumno.aspx"
        case .schedule:
            baseURL + "Alumnos/Informacion_semestral/Horario_Alumno.aspx"
        case .grades:
            baseURL + "Alumnos/Informacion_semestral/calificaciones_sem.aspx"
        case .kardex:
            baseURL + "Alumnos/boleta/kardex.aspx"
        case .personalPhoto:
            baseURL + "Alumnos/info_alumnos/Fotografia.aspx"
        case .academic:
            baseURL + "academica"
        }
    }
}
