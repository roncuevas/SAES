import Foundation

enum MenuConfiguration {
    case login
    case logged

    var elements: [MenuElement] {
        switch self {
        case .login:
            return [.news, .ipnSchedule, .debug]
        case .logged:
            return [.credential, .scheduleReceipt, .news, .ipnSchedule, .scheduleAvailability, .settings, .debug, .feedback]
        }
    }
}
