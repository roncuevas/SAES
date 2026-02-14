import Foundation

struct SAESDailySchedule: Identifiable, Sendable {
    let id: UUID = UUID()
    let day: SAESDays?
    let time: String?
}
