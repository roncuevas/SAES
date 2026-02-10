import Foundation

enum URLConstants {
    private static let externalURLs: ExternalURLsConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(ExternalURLsConfiguration.self, from: "external_urls")
    }()

    // MARK: - Webcal
    static var webcalInPerson: String { externalURLs.webcal.inPerson }
    static var webcalRemote: String { externalURLs.webcal.remote }

    // MARK: - App
    static var feedbackForm: String { externalURLs.app.feedbackForm }
    static var testFlight: String { externalURLs.app.testFlight }
    static var appStoreReview: String { externalURLs.app.appStoreReview }

    // MARK: - API
    static var apiBase: String { externalURLs.api.base }
    static var scraperJS: String { externalURLs.api.base + externalURLs.api.scraperJS }
    static var ipnStatements: String { externalURLs.api.base + externalURLs.api.ipnStatements }
    static var ipnSchedule: String { externalURLs.api.base + externalURLs.api.ipnSchedule }

    // MARK: - IPN
    static var ipnBase: String { externalURLs.ipn.base }

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
        UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.saesURL) ?? ""
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
