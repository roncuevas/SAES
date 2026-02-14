import Foundation

struct AvailableSchool: Codable, Identifiable, Sendable {
    var id: String { schoolCode }
    let portalURL: String
    let schoolCode: String
    let name: String
    let logoURL: String
}
