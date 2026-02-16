import Foundation

enum MenuConfiguration {
    case login
    case logged

    var items: [MenuItem] {
        switch self {
        case .login:
            return [
                .element(.news),
                .element(.ipnSchedule),
                .element(.debug)
            ]
        case .logged:
            return [
                .element(.credential),
                .element(.news),
                .element(.ipnSchedule),
                .element(.scheduleAvailability),
                .submenu(
                    id: "others",
                    title: Localization.others,
                    icon: "ellipsis.circle",
                    children: [.scheduleReceipt]
                ),
                .element(.settings),
                .element(.feedback),
                .element(.debug)
            ]
        }
    }
}
