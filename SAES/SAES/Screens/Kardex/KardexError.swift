import Foundation

enum KardexError: Error, LocalizedError {
    case noPanelFound
    case dataParsingFailed

    var errorDescription: String? {
        switch self {
        case .noPanelFound:
            return "No se encontró el panel del kardex"
        case .dataParsingFailed:
            return "No se pudo parsear el kardex"
        }
    }
}
