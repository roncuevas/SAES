import WidgetKit

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let classes: [WidgetClassItem]
    let nextClass: WidgetClassItem?
    let currentClass: WidgetClassItem?
    let dayName: String
    let isToday: Bool
    let isEmpty: Bool
}
