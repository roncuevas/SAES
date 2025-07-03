import Foundation

enum SAESParserError: Error, LocalizedError {
    case dataIsNotUTF8
    case nodeNotFound

    var errorDescription: String? {
        switch self {
            case .dataIsNotUTF8:
            return "Data no esta en UTF8"
        case .nodeNotFound:
            return "Nodo no encontrado"
        }
    }
}
