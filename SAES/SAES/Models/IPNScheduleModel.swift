import Foundation

struct IPNScheduleModel: Codable, Hashable {
    let year: Int
    let month: Int
    let events: [IPNScheduleEvent]
}

struct IPNScheduleEvent: Codable, Hashable {
    let name: String
    let type: String
    let dateRange: IPNDateRange

    enum CodingKeys: String, CodingKey {
        case name = "event_name"
        case type = "event_type"
        case dateRange = "range"
    }
}

struct IPNDateRange: Codable, Hashable {
    let start: String
    let end: String
}

typealias IPNScheduleResponse = [IPNScheduleModel]
