import Foundation

struct OfflineCache: Codable, Sendable {
    var grades: [Grupo]
    var kardex: KardexModel?
    var schedule: [ScheduleItem]
    var personalData: [String: String]
    var lastUpdated: Date
}
