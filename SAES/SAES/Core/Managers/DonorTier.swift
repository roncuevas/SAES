import Foundation

enum DonorTier: Comparable, Sendable {
    case none
    case supporter
    case patron
    case champion

    var hearts: String {
        switch self {
        case .none: ""
        case .supporter: "❤️"
        case .patron: "❤️❤️"
        case .champion: "❤️❤️❤️"
        }
    }
}
