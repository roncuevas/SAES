import WidgetKit

struct IPNEventsEntry: TimelineEntry {
    let date: Date
    let events: [IPNScheduleEvent]
    let isEmpty: Bool
}
