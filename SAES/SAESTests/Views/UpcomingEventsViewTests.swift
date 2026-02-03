import XCTest
@testable import SAES

final class UpcomingEventsViewTests: XCTestCase {

    // MARK: - validEvents filter tests

    func testValidEventsFiltersOutPastEvents() {
        let pastEvent = IPNScheduleEvent(
            name: "Evento pasado",
            type: "vacations",
            dateRange: IPNDateRange(start: "2020-01-01", end: "2020-01-05")
        )
        let events = [pastEvent]
        XCTAssertTrue(events.validEvents.isEmpty)
    }

    func testValidEventsIncludesFutureEventsWithin60Days() {
        let calendar = Calendar.current
        let futureStart = calendar.date(byAdding: .day, value: 10, to: Date())!
        let futureEnd = calendar.date(byAdding: .day, value: 15, to: Date())!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let futureEvent = IPNScheduleEvent(
            name: "Evento futuro",
            type: "ordinary_evaluation",
            dateRange: IPNDateRange(
                start: formatter.string(from: futureStart),
                end: formatter.string(from: futureEnd)
            )
        )
        let events = [futureEvent]
        XCTAssertEqual(events.validEvents.count, 1)
    }

    func testValidEventsFiltersOutEventsBeyond60Days() {
        let calendar = Calendar.current
        let farFutureStart = calendar.date(byAdding: .day, value: 100, to: Date())!
        let farFutureEnd = calendar.date(byAdding: .day, value: 105, to: Date())!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let farEvent = IPNScheduleEvent(
            name: "Evento lejano",
            type: "vacations",
            dateRange: IPNDateRange(
                start: formatter.string(from: farFutureStart),
                end: formatter.string(from: farFutureEnd)
            )
        )
        let events = [farEvent]
        XCTAssertTrue(events.validEvents.isEmpty)
    }

    func testValidEventsIncludesOngoingEvents() {
        let calendar = Calendar.current
        let pastStart = calendar.date(byAdding: .day, value: -5, to: Date())!
        let futureEnd = calendar.date(byAdding: .day, value: 5, to: Date())!

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let ongoingEvent = IPNScheduleEvent(
            name: "Evento en curso",
            type: "ordinary_evaluation",
            dateRange: IPNDateRange(
                start: formatter.string(from: pastStart),
                end: formatter.string(from: futureEnd)
            )
        )
        let events = [ongoingEvent]
        XCTAssertEqual(events.validEvents.count, 1)
    }

    func testValidEventsWithInvalidDatesReturnsEmpty() {
        let invalidEvent = IPNScheduleEvent(
            name: "Evento invalido",
            type: "vacations",
            dateRange: IPNDateRange(start: "invalid", end: "invalid")
        )
        let events = [invalidEvent]
        XCTAssertTrue(events.validEvents.isEmpty)
    }

    func testEmptyScheduleReturnsNoEvents() {
        let schedule: [IPNScheduleModel] = []
        let allEvents = schedule.flatMap { $0.events }.validEvents
        XCTAssertTrue(allEvents.isEmpty)
    }

    func testScheduleWithOnlyPastEventsReturnsEmpty() {
        let pastEvents = [
            IPNScheduleEvent(
                name: "Vacaciones 2020",
                type: "vacations",
                dateRange: IPNDateRange(start: "2020-01-01", end: "2020-01-15")
            ),
            IPNScheduleEvent(
                name: "Examen 2021",
                type: "ordinary_evaluation",
                dateRange: IPNDateRange(start: "2021-05-01", end: "2021-05-05")
            )
        ]
        let schedule = [
            IPNScheduleModel(year: 2020, month: 1, events: [pastEvents[0]]),
            IPNScheduleModel(year: 2021, month: 5, events: [pastEvents[1]])
        ]
        let allEvents = schedule.flatMap { $0.events }.validEvents
        XCTAssertTrue(allEvents.isEmpty)
    }
}
