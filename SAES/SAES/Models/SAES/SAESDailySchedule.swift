import Foundation

struct SAESDailySchedule: Identifiable {
    let id: UUID = UUID()
    let day: SAESDays?
    let time: String?
}
