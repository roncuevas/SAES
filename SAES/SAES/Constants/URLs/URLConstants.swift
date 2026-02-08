import Foundation

enum URLConstants {
    // MARK: - Webcal
    static let webcalInPerson = "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhEaeX9yo2IzCtXF7e3JFtL2SOmACjtKtVR0JLwWw0MnZx-BSTirzVm6i_io5cefxs"
    static let webcalRemote = "webcal://p146-caldav.icloud.com/published/2/OTIxNjU3NzE0OTIxNjU3N8BecDTVCw2KHU-1efVR3QhSvIzLpzwBxfL-5Lf8KB84vOp_4HGv_bJ1AJpJEi-tIxEmCieJk8KFOPhlSWdlfRo"

    // MARK: - App
    static let feedbackForm = "https://forms.gle/9GP2Mc74urEP54vz9"
    static let testFlight = "https://testflight.apple.com/join/chRbe5EF"
    static let appStoreReview = "https://apps.apple.com/app/id6467482580?action=write-review"

    // MARK: - API
    static let apiBase = "https://api.roncuevas.com"
    static let scraperJS = "\(apiBase)/files/ipn_scrapper_encrypted.js"
    static let ipnStatements = "\(apiBase)/ipn/statements"
    static let ipnSchedule = "\(apiBase)/ipn/schedule"

    // MARK: - IPN
    static let ipnBase = "https://www.ipn.mx"

    // MARK: - SAES Routes
    case base
    case standard
    case home
    case personalData
    case schedule
    case grades
    case kardex
    case personalPhoto
    case academic
    case evalTeachersBase
    case evalTeachers
    case schedulePDF
    case scheduleAvailability

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
        case .evalTeachersBase:
            baseURL + "Alumnos/Evaluacion_docente/"
        case .evalTeachers:
            baseURL + "Alumnos/Evaluacion_docente/califica_profe.aspx"
        case .schedulePDF:
            baseURL + "Alumnos/Informacion_semestral/HorarioAlumnoPDF.aspx"
        case .scheduleAvailability:
            baseURL + "Academica/horarios.aspx"
        }
    }
}
