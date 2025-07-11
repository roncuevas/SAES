import Foundation

enum GradesError: Error, LocalizedError {
    case evaluateTeachers
    case dataParsingFailed
    case noTableFound
    case nilHeaders
    case noEvaluationTableFound

    var errorDescription: String? {
        switch self {
        case .evaluateTeachers:
            return "Falta evaluar profesores"
        case .dataParsingFailed:
            return "No se pudo parsear el HTML"
        case .noTableFound:
            return "No se encontro la tabla de calificaciones"
        case .nilHeaders:
            return "No se encontraron los encabezados de la tabla de calificaciones"
        case .noEvaluationTableFound:
            return "No se encontró la tabla de evaluaciones de profesores"
        }
    }
}
