import Foundation
import EventKit
import EventKitUI

class EventManager {
    static let weekDays = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
    static let shared: EventManager = EventManager()
    let eventStore = EKEventStore()
    
    private init() {}
    
    static func getWeeklyEvent(eventStore: EKEventStore = EKEventStore(),
                               eventTitle: String,
                               startingOnDayOfWeek dayOfWeek: String,
                               startTime: String?,
                               endTime: String?,
                               until endDate: Date?) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.title = eventTitle
        guard let startTime else { return event }
        let nextDayOfWeekDate = Date.getNextDayOfWeek(dayOfWeek, startTime: startTime)
        event.startDate = nextDayOfWeekDate
        guard let endTime else { return event }
        event.endDate = nextDayOfWeekDate.addingTimeInterval(Date.getDuration(startTime: startTime, endTime: endTime))
        guard let endDate else { return event }
        let recurrenceEnd: EKRecurrenceEnd? = EKRecurrenceEnd(end: endDate)
        let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: recurrenceEnd)
        event.addRecurrenceRule(recurrenceRule)
        return event
    }
}
