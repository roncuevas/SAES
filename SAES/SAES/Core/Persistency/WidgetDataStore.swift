import Foundation
import WidgetKit

struct WidgetSchoolInfo: Codable, Sendable {
    let schoolCode: String
    let schoolName: String
}

final class WidgetDataStore: @unchecked Sendable {
    static let shared = WidgetDataStore()

    private let suiteName = "group.com.roncuevas.saes-app"
    private let ipnEventsKey = "widget_ipn_events.json"
    private let manifestKey = "widget_schools.json"

    private var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
    }

    // MARK: - Schedule (per-school)

    func saveSchedule(_ items: [ScheduleItem], schoolCode: String) {
        save(items, fileName: scheduleFileName(for: schoolCode))
    }

    func loadSchedule(schoolCode: String) -> [ScheduleItem] {
        load(fileName: scheduleFileName(for: schoolCode)) ?? []
    }

    func removeSchedule(schoolCode: String) {
        delete(fileName: scheduleFileName(for: schoolCode))
    }

    // MARK: - Schools Manifest

    func saveSchoolsManifest(_ schools: [WidgetSchoolInfo]) {
        save(schools, fileName: manifestKey)
    }

    func loadSchoolsManifest() -> [WidgetSchoolInfo] {
        load(fileName: manifestKey) ?? []
    }

    func addSchoolToManifest(schoolCode: String, schoolName: String) {
        var manifest = loadSchoolsManifest()
        if !manifest.contains(where: { $0.schoolCode == schoolCode }) {
            manifest.append(WidgetSchoolInfo(schoolCode: schoolCode, schoolName: schoolName))
            saveSchoolsManifest(manifest)
        }
    }

    func removeSchoolFromManifest(schoolCode: String) {
        var manifest = loadSchoolsManifest()
        manifest.removeAll { $0.schoolCode == schoolCode }
        saveSchoolsManifest(manifest)
    }

    // MARK: - IPN Events (global)

    func saveIPNEvents(_ events: [IPNScheduleEvent]) {
        save(events, fileName: ipnEventsKey)
    }

    func loadIPNEvents() -> [IPNScheduleEvent] {
        load(fileName: ipnEventsKey) ?? []
    }

    // MARK: - Cleanup

    func clearSchool(_ schoolCode: String) {
        removeSchedule(schoolCode: schoolCode)
        removeSchoolFromManifest(schoolCode: schoolCode)
    }

    func clearAll() {
        let manifest = loadSchoolsManifest()
        for school in manifest {
            delete(fileName: scheduleFileName(for: school.schoolCode))
        }
        delete(fileName: manifestKey)
        delete(fileName: ipnEventsKey)
    }

    func reloadAllWidgets() {
        WidgetCenter.shared.reloadTimelines(ofKind: "ScheduleWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "IPNEventsWidget")
    }

    // MARK: - Private

    private func scheduleFileName(for schoolCode: String) -> String {
        "widget_schedule_\(schoolCode).json"
    }

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
