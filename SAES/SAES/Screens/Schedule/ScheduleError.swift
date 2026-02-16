import Foundation

enum ScheduleError: Error, LocalizedError {
    case noTableFound
    case dataParsingFailed

    var errorDescription: String? {
        switch self {
        case .noTableFound:
            return "No se encontró la tabla de horario"
        case .dataParsingFailed:
            return "No se pudo parsear el horario"
        }
    }
}
