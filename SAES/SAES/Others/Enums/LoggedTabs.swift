import Foundation

enum LoggedTabs {
    case personalData
    case schedules
    case grades
    case kardex

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
        }
    }
}

extension Localization {
    static let personalData = NSLocalizedString("Personal Data", comment: "")
    static let schedule = NSLocalizedString("Schedule", comment: "")
    static let grades = NSLocalizedString("Grades", comment: "")
    static let kardex = NSLocalizedString("Kardex", comment: "")
}
