import Foundation

extension Array where Element == IPNScheduleEvent {
    var validEvents: Self {
        self.compactMap { event in
            // let _ = Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now
            let limit = DateInterval(
                start: Date.now,
                end: Calendar.current.date(byAdding: .day, value: 60, to: .now) ?? .now
            )
            guard let interval = event.dateRange.toDateInterval else { return nil }
            guard interval.intersects(limit) else { return nil }
            return event
        }
    }
}
