import WidgetKit

struct ScheduleTimelineProvider: TimelineProvider {
    private let store = WidgetDataStore.shared

    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            classes: [],
            nextClass: nil,
            currentClass: nil,
            dayName: "Lunes",
            isToday: true,
            isEmpty: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> Void) {
        completion(buildEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> Void) {
        let now = Date()
        let entry = buildEntry(date: now)

        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func buildEntry(date: Date) -> ScheduleEntry {
        let items = store.loadSchedule()
        guard !items.isEmpty else {
            return ScheduleEntry(
                date: date,
                classes: [],
                nextClass: nil,
                currentClass: nil,
                dayName: "",
                isToday: false,
                isEmpty: true
            )
        }

        let result = WidgetScheduleBuilder.buildClasses(from: items, for: date)
        let next = result.isToday ? WidgetScheduleBuilder.nextClass(from: result.classes, at: date) : result.classes.first
        let current = result.isToday ? WidgetScheduleBuilder.currentClass(from: result.classes, at: date) : nil

        return ScheduleEntry(
            date: date,
            classes: result.classes,
            nextClass: next,
            currentClass: current,
            dayName: result.dayName,
            isToday: result.isToday,
            isEmpty: result.classes.isEmpty
        )
    }
}
