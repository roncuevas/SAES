import Foundation

extension IPNScheduleModel {
    var validEvents: [IPNScheduleEvent] {
        self.events.compactMap { event in
            guard let interval = event.dateRange.toDateInterval,
                  interval.intersects(.init(start: .now - 604_800,
                                            duration: 5_184_000)) else { return nil }
            return event
        }
    }
}
