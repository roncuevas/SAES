import Foundation

enum MenuConfiguration {
    case login
    case logged

    var items: [MenuItem] {
        switch self {
        case .login:
            return [
                .element(.credential),
                .element(.news),
                .element(.announcements),
                .element(.scholarships),
                .element(.ipnSchedule),
                .submenu(
                    id: "others",
                    title: Localization.others,
                    icon: "ellipsis.circle",
                    children: [.scheduleReceipt, .privacyPolicy]
                ),
                .element(.settings),
                .element(.debug)
            ]
        case .logged:
            return [
                .element(.credential),
                .element(.news),
                .element(.announcements),
                .element(.scholarships),
                .element(.ipnSchedule),
                .submenu(
                    id: "others",
                    title: Localization.others,
                    icon: "ellipsis.circle",
                    children: [.scheduleReceipt, .privacyPolicy]
                ),
                .element(.settings),
                .element(.feedback),
                .element(.debug)
            ]
        }
    }
}
