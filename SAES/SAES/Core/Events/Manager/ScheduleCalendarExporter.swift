import EventKit
import Foundation

@MainActor
final class ScheduleCalendarExporter: ObservableObject {
    enum AlarmOffset: Int, CaseIterable, Identifiable {
        case five = 5
        case ten = 10
        case fifteen = 15

        var id: Int { rawValue }

        var relativeOffset: TimeInterval {
            TimeInterval(-rawValue * 60)
        }

        var displayText: String {
            "\(rawValue) min"
        }
    }

    enum ExportError: Error {
        case calendarAccessDenied
        case noScheduleData
        case endDateFetchFailed
        case noCalendarSource
    }

    @Published var isExporting = false
    @Published var isAddedToCalendar = false

    private let eventStore = EKEventStore()
    private static let calendarTitle = "SAES"

    func checkIfExported() {
        isAddedToCalendar = findExistingCalendar() != nil
    }

    func exportSchedule(
        items: [ScheduleItem],
        horarioSemanal: HorarioSemanal,
        alarmOffset: AlarmOffset
    ) async throws -> Int {
        isExporting = true
        defer { isExporting = false }

        try await requestAccess()

        guard !items.isEmpty else { throw ExportError.noScheduleData }

        let calendar = try getOrCreateCalendar()
        let endDate = try await fetchSemesterEndDate()

        var savedCount = 0
        let dayNames = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"]

        for item in items {
            for day in dayNames {
                guard let rangoString = item[dynamicMember: day],
                      !rangoString.isEmpty else { continue }

                let rangos = HorarioSemanal().convertirRangoEnHorarios(rangoHoras: rangoString)

                for rango in rangos {
                    let event = EventManager.getWeeklyEvent(
                        eventStore: eventStore,
                        eventTitle: item.materia,
                        startingOnDayOfWeek: day.capitalized,
                        startTime: rango.inicio,
                        endTime: rango.fin,
                        until: endDate,
                        calendar: calendar
                    )

                    event.location = buildLocation(from: item)
                    event.notes = item.profesores.capitalized
                    event.addAlarm(EKAlarm(relativeOffset: alarmOffset.relativeOffset))

                    try eventStore.save(event, span: .futureEvents)
                    savedCount += 1
                }
            }
        }

        isAddedToCalendar = true
        return savedCount
    }

    func removeSchedule() throws {
        guard let calendar = findExistingCalendar() else { return }
        try eventStore.removeCalendar(calendar, commit: true)
        UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.scheduleCalendarId)
        isAddedToCalendar = false
    }

    // MARK: - Private

    private func findExistingCalendar() -> EKCalendar? {
        let savedId = UserDefaults.standard.string(forKey: AppConstants.UserDefaultsKeys.scheduleCalendarId)

        if let savedId,
           let calendar = eventStore.calendars(for: .event).first(where: { $0.calendarIdentifier == savedId }) {
            return calendar
        }

        if let calendar = eventStore.calendars(for: .event).first(where: { $0.title == Self.calendarTitle }) {
            UserDefaults.standard.set(calendar.calendarIdentifier, forKey: AppConstants.UserDefaultsKeys.scheduleCalendarId)
            return calendar
        }

        if savedId != nil {
            UserDefaults.standard.removeObject(forKey: AppConstants.UserDefaultsKeys.scheduleCalendarId)
        }

        return nil
    }

    private func getOrCreateCalendar() throws -> EKCalendar {
        if let existing = findExistingCalendar() {
            return existing
        }

        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.title = Self.calendarTitle

        let sources = eventStore.sources
        if let calDAV = sources.first(where: { $0.sourceType == .calDAV }) {
            calendar.source = calDAV
        } else if let local = sources.first(where: { $0.sourceType == .local }) {
            calendar.source = local
        } else {
            throw ExportError.noCalendarSource
        }

        try eventStore.saveCalendar(calendar, commit: true)
        UserDefaults.standard.set(calendar.calendarIdentifier, forKey: AppConstants.UserDefaultsKeys.scheduleCalendarId)

        return calendar
    }

    private func requestAccess() async throws {
        let granted: Bool
        if #available(iOS 17.0, *) {
            granted = try await eventStore.requestFullAccessToEvents()
        } else {
            granted = try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { result, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: result)
                    }
                }
            }
        }
        guard granted else { throw ExportError.calendarAccessDenied }
    }

    private func fetchSemesterEndDate() async throws -> Date {
        let response = try await NetworkManager.shared.sendRequest(
            url: "https://api.roncuevas.com/ipn/v1/limits",
            type: SchoolLimitsResponse.self
        )
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: response.end) else {
            throw ExportError.endDateFetchFailed
        }
        return date
    }

    private func buildLocation(from item: ScheduleItem) -> String? {
        func clean(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespaces),
                  !trimmed.isEmpty, trimmed != "-" else { return nil }
            return trimmed
        }

        let parts = [
            clean(item.edificio).map { Localization.building.space + $0 },
            clean(item.salon).map { Localization.classroom.space + $0 }
        ].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
