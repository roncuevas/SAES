import WidgetKit

struct ScheduleTimelineProvider: AppIntentTimelineProvider {
    private let store = WidgetDataStore.shared

    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            classes: [],
            nextClass: nil,
            currentClass: nil,
            dayName: "Lunes",
            schoolName: "",
            isToday: true,
            isEmpty: false
        )
    }

    func snapshot(for configuration: SelectSchoolIntent, in context: Context) async -> ScheduleEntry {
        buildEntry(date: Date(), configuration: configuration)
    }

    func timeline(for configuration: SelectSchoolIntent, in context: Context) async -> Timeline<ScheduleEntry> {
        let now = Date()
        let entry = buildEntry(date: now, configuration: configuration)

        let nextMidnight = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: now)!)
        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }

    private func buildEntry(date: Date, configuration: SelectSchoolIntent) -> ScheduleEntry {
        guard let school = configuration.school else {
            // No school selected — try first available
            let manifest = store.loadSchoolsManifest()
            guard let first = manifest.first else {
                return emptyEntry(date: date, schoolName: "")
            }
            return buildEntryForSchool(code: first.schoolCode, name: first.schoolName, date: date)
        }

        return buildEntryForSchool(code: school.id, name: school.name, date: date)
    }

    private func buildEntryForSchool(code: String, name: String, date: Date) -> ScheduleEntry {
        let items = store.loadSchedule(schoolCode: code)
        guard !items.isEmpty else {
            return emptyEntry(date: date, schoolName: name)
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
            schoolName: name,
            isToday: result.isToday,
            isEmpty: result.classes.isEmpty
        )
    }

    private func emptyEntry(date: Date, schoolName: String) -> ScheduleEntry {
        ScheduleEntry(
            date: date,
            classes: [],
            nextClass: nil,
            currentClass: nil,
            dayName: "",
            schoolName: schoolName,
            isToday: false,
            isEmpty: true
        )
    }
}
