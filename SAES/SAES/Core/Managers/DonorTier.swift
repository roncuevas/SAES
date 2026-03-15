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

    var icon: String {
        switch self {
        case .none: ""
        case .supporter: "heart.fill"
        case .patron: "star.fill"
        case .champion: "crown.fill"
        }
    }
}
