import Foundation

enum DonorTier: Comparable, Sendable {
    case none
    case supporter
    case patron
    case champion

    var label: String {
        switch self {
        case .none: ""
        case .supporter: Localization.donorSupporter
        case .patron: Localization.donorPatron
        case .champion: Localization.donorChampion
        }
    }

    var hearts: String {
        switch self {
        case .none: ""
        case .supporter: "❤️"
        case .patron: "❤️❤️"
        case .champion: "❤️❤️❤️"
        }
    }
}
