import Foundation

struct SAESScheduleSubject: Identifiable {
    let id: UUID = UUID()
    let group: String?
    let name: String?
    let teacher: String?
    let schedule: [SAESDailySchedule]?
    let building: String?
    let classroom: String?
}
