import Foundation

enum CredentialError: LocalizedError {
    case storageError
    case invalidQRData
    case exportFailed
    case parsingFailed
    case networkError

    var errorDescription: String? {
        switch self {
        case .storageError:
            return "Error accessing credential storage"
        case .invalidQRData:
            return "Invalid QR code data"
        case .exportFailed:
            return "Failed to export credential image"
        case .parsingFailed:
            return "Failed to parse credential data"
        case .networkError:
            return "Failed to fetch credential data"
        }
    }
}
