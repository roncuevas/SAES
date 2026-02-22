import Foundation

struct IPNScheduleEvent: Codable, Hashable, Sendable {
    let name: String
    let type: String
    let start: String
    let end: String

    enum CodingKeys: String, CodingKey {
        case name = "event_name"
        case type = "event_type"
        case start
        case end
    }
}

typealias IPNScheduleResponse = [IPNScheduleEvent]
