import WidgetKit

struct IPNEventsTimelineProvider: TimelineProvider {
    private let store = WidgetDataStore.shared

    func placeholder(in context: Context) -> IPNEventsEntry {
        IPNEventsEntry(date: Date(), events: [], isEmpty: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (IPNEventsEntry) -> Void) {
        completion(buildEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IPNEventsEntry>) -> Void) {
        let now = Date()
        let entry = buildEntry(date: now)

        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func buildEntry(date: Date) -> IPNEventsEntry {
        let allEvents = store.loadIPNEvents()
        guard !allEvents.isEmpty else {
            return IPNEventsEntry(date: date, events: [], isEmpty: true)
        }

        let upcoming = allEvents.validEvents
            .sorted { ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture) }

        return IPNEventsEntry(date: date, events: upcoming, isEmpty: upcoming.isEmpty)
    }
}
