import Foundation
import WidgetKit

final class WidgetDataStore: @unchecked Sendable {
    static let shared = WidgetDataStore()

    private let suiteName = "group.com.roncuevas.saes-app"
    private let scheduleKey = "widget_schedule.json"
    private let ipnEventsKey = "widget_ipn_events.json"

    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
    }

    // MARK: - Schedule

    func saveSchedule(_ items: [ScheduleItem]) {
        save(items, fileName: scheduleKey)
    }

    func loadSchedule() -> [ScheduleItem] {
        load(fileName: scheduleKey) ?? []
    }

    // MARK: - IPN Events

    func saveIPNEvents(_ events: [IPNScheduleEvent]) {
        save(events, fileName: ipnEventsKey)
    }

    func loadIPNEvents() -> [IPNScheduleEvent] {
        load(fileName: ipnEventsKey) ?? []
    }

    // MARK: - Cleanup

    func clearAll() {
        delete(fileName: scheduleKey)
        delete(fileName: ipnEventsKey)
    }

    func reloadAllWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "ScheduleWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "IPNEventsWidget")
    }

    // MARK: - Private

    private func save<T: Encodable>(_ value: T, fileName: String) {
        guard let url = containerURL?.appendingPathComponent(fileName) else { return }
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            // Silently fail - widget data is non-critical
        }
    }

    private func load<T: Decodable>(fileName: String) -> T? {
        guard let url = containerURL?.appendingPathComponent(fileName),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func delete(fileName: String) {
        guard let url = containerURL?.appendingPathComponent(fileName) else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
