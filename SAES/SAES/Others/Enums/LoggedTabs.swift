import Foundation

enum LoggedTabs: String {
    case personalData
    case schedules
    case grades
    case kardex
    case home

    var value: String {
        switch self {
        case .personalData:
            return Localization.personalData
        case .schedules:
            return Localization.schedule
        case .grades:
            return Localization.grades
        case .kardex:
            return Localization.kardex
        case .home:
            return Localization.home
        }
    }
}
