import Foundation

enum SAESDays: Int {
    case monday = 0
    case tuesday = 1
    case wednesday = 2
    case thursday = 3
    case friday = 4
    case saturday = 5
    case sunday = 6

    var shortName: String {
        return switch self {
        case .monday: "Lun"
        case .tuesday: "Mar"
        case .wednesday: "Mie"
        case .thursday: "Jue"
        case .friday: "Vie"
        case .saturday: "Sab"
        case .sunday: "Dom"
        }
    }
}
