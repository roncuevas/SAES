import Foundation

extension Array where Element == IPNScheduleEvent {
    var validEvents: Self {
        validEvents(days: 60)
    }

    func validEvents(days: Int) -> Self {
        let limit = DateInterval(
            start: .now,
            end: Calendar.current.date(byAdding: .day, value: days, to: .now) ?? .now
        )
        return self.compactMap { event in
            guard let interval = event.toDateInterval else { return nil }
            guard interval.intersects(limit) else { return nil }
            return event
        }
    }
}
