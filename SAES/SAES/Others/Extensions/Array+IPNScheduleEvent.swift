import Foundation

extension Array where Element == IPNScheduleEvent {
    var validEvents: Self {
        let limit = DateInterval(
            start: .now,
            end: Calendar.current.date(byAdding: .day, value: 60, to: .now) ?? .now
        )
        return self.compactMap { event in
            guard let interval = event.toDateInterval else { return nil }
            guard interval.intersects(limit) else { return nil }
            return event
        }
    }
}
