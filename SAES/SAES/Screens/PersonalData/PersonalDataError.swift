import Foundation

enum PersonalDataError: Error, LocalizedError {
    case dataIsNotUTF8
    case elementNotFound
}
