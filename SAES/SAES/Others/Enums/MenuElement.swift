import Foundation

enum MenuElement: Hashable {
    case news
    case ipnSchedule
    case scheduleAvailability
    case scheduleReceipt
    case credential
    case debug
    case feedback
    case rateApp
    case settings
    case logout
}

enum MenuItem: Identifiable {
    case element(MenuElement)
    case submenu(id: String, title: String, icon: String, children: [MenuElement])

    var id: String {
        switch self {
        case .element(let element): return "element_\(element)"
        case .submenu(let id, _, _, _): return "submenu_\(id)"
        }
    }
}
