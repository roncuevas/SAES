import Foundation
import EventKit
import EventKitUI

class EventManager {
    static let weekDays = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
    static let shared: EventManager = EventManager()
    
    private init() {
        
    }
    
    static func getWeeklyEvent(eventTitle: String,
                               startingOnDayOfWeek dayOfWeek: String,
                               startTime: String?,
                               endTime: String?,
                               until endDate: Date?) -> EKEvent {
        let eventStore = EKEventStore()
        // Crear un nuevo evento
        let event = EKEvent(eventStore: eventStore)
        event.calendar = eventStore.defaultCalendarForNewEvents
        event.title = eventTitle
        guard let startTime else { return event }
        // Determinar la próxima fecha del día de la semana especificado
        let nextDayOfWeekDate = Date.getNextDayOfWeek(dayOfWeek, startTime: startTime)
        event.startDate = nextDayOfWeekDate
        guard let endTime else { return event }
        event.endDate = nextDayOfWeekDate.addingTimeInterval(Date.getDuration(startTime: startTime, endTime: endTime))
        // Configurar la regla de recurrencia hasta una fecha específica
        var recurrenceEnd: EKRecurrenceEnd? = nil
        if let endDate {
            recurrenceEnd = EKRecurrenceEnd(end: endDate)
        }
        let recurrenceRule = EKRecurrenceRule(recurrenceWith: .weekly, interval: 1, end: recurrenceEnd)
        event.addRecurrenceRule(recurrenceRule)
        return event
    }
}
