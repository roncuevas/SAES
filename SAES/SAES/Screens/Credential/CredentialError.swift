import Foundation

enum CredentialError: LocalizedError {
    case storageError
    case invalidQRData
    case exportFailed

    var errorDescription: String? {
        switch self {
        case .storageError:
            return "Error accessing credential storage"
        case .invalidQRData:
            return "Invalid QR code data"
        case .exportFailed:
            return "Failed to export credential image"
        }
    }
}
