import Foundation

struct AvailableSchool: Codable, Identifiable {
    var id: String { schoolCode }
    let portalURL: String
    let schoolCode: String
    let name: String
    let logoURL: String
}
