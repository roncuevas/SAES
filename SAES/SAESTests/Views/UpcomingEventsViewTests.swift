import XCTest
@testable import SAES

final class UpcomingEventsViewTests: XCTestCase {

    // MARK: - validEvents filter tests

    func testValidEventsFiltersOutPastEvents() {
        let pastEvent = IPNScheduleEvent(
            name: "Evento pasado",
            type: "vacations",
            start: "2020-01-01",
            end: "2020-01-05"
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
            start: formatter.string(from: futureStart),
            end: formatter.string(from: futureEnd)
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
            start: formatter.string(from: farFutureStart),
            end: formatter.string(from: farFutureEnd)
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
            start: formatter.string(from: pastStart),
            end: formatter.string(from: futureEnd)
        )
        let events = [ongoingEvent]
        XCTAssertEqual(events.validEvents.count, 1)
    }

    func testValidEventsWithInvalidDatesReturnsEmpty() {
        let invalidEvent = IPNScheduleEvent(
            name: "Evento invalido",
            type: "vacations",
            start: "invalid",
            end: "invalid"
        )
        let events = [invalidEvent]
        XCTAssertTrue(events.validEvents.isEmpty)
    }

    func testEmptyScheduleReturnsNoEvents() {
        let schedule: [IPNScheduleEvent] = []
        XCTAssertTrue(schedule.validEvents.isEmpty)
    }

    func testScheduleWithOnlyPastEventsReturnsEmpty() {
        let pastEvents = [
            IPNScheduleEvent(
                name: "Vacaciones 2020",
                type: "vacations",
                start: "2020-01-01",
                end: "2020-01-15"
            ),
            IPNScheduleEvent(
                name: "Examen 2021",
                type: "ordinary_evaluation",
                start: "2021-05-01",
                end: "2021-05-05"
            )
        ]
        XCTAssertTrue(pastEvents.validEvents.isEmpty)
    }
}
