import XCTest
@testable import SAES

final class IPNScheduleModelTests: XCTestCase {

    // MARK: - IPNScheduleEvent decoding

    func testDecodeEventCodingKeys() throws {
        let json = """
        {
            "event_name": "Evaluacion extraordinaria",
            "event_type": "extraordinary_evaluation",
            "start": "2025-06-10",
            "end": "2025-06-20"
        }
        """
        let event = try JSONDecoder().decode(IPNScheduleEvent.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(event.name, "Evaluacion extraordinaria")
        XCTAssertEqual(event.type, "extraordinary_evaluation")
        XCTAssertEqual(event.start, "2025-06-10")
        XCTAssertEqual(event.end, "2025-06-20")
    }

    func testEncodeEventUsesCorrectKeys() throws {
        let event = IPNScheduleEvent(
            name: "Fin de semestre",
            type: "period_end",
            start: "2025-12-12",
            end: "2025-12-12"
        )
        let data = try JSONEncoder().encode(event)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("Failed to serialize encoded event")
        }
        XCTAssertNotNil(dict["event_name"])
        XCTAssertNotNil(dict["event_type"])
        XCTAssertNotNil(dict["start"])
        XCTAssertNotNil(dict["end"])
        XCTAssertNil(dict["name"])
        XCTAssertNil(dict["type"])
    }

    // MARK: - IPNScheduleResponse (flat array)

    func testDecodeFullResponse() throws {
        let json = """
        [
            {
                "event_name": "Inicio de semestre",
                "event_type": "period_start",
                "start": "2025-01-06",
                "end": "2025-01-06"
            },
            {
                "event_name": "Vacaciones de Semana Santa",
                "event_type": "vacations",
                "start": "2025-04-14",
                "end": "2025-04-25"
            }
        ]
        """
        let response = try JSONDecoder().decode(IPNScheduleResponse.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(response.count, 2)
        XCTAssertEqual(response[0].name, "Inicio de semestre")
        XCTAssertEqual(response[1].name, "Vacaciones de Semana Santa")
    }

    func testDecodeEmptyResponse() throws {
        let json = "[]"
        let response = try JSONDecoder().decode(IPNScheduleResponse.self, from: json.data(using: .utf8)!)
        XCTAssertTrue(response.isEmpty)
    }

    // MARK: - Date properties

    func testStartAndEndDates() {
        let event = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "2025-03-15",
            end: "2025-03-20"
        )
        XCTAssertNotNil(event.startDate)
        XCTAssertNotNil(event.endDate)

        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: event.startDate!)
        XCTAssertEqual(startComponents.year, 2025)
        XCTAssertEqual(startComponents.month, 3)
        XCTAssertEqual(startComponents.day, 15)
    }

    func testInvalidDateReturnsNil() {
        let event = IPNScheduleEvent(
            name: "Invalid",
            type: "vacations",
            start: "invalid",
            end: "also-invalid"
        )
        XCTAssertNil(event.startDate)
        XCTAssertNil(event.endDate)
        XCTAssertNil(event.toDateInterval)
    }

    func testToDateInterval() {
        let event = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "2025-01-01",
            end: "2025-01-31"
        )
        let interval = event.toDateInterval
        XCTAssertNotNil(interval)
        XCTAssertTrue(interval!.duration > 0)
    }

    func testToStringIntervalNotEmpty() {
        let event = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "2025-04-14",
            end: "2025-04-25"
        )
        let str = event.toStringInterval
        XCTAssertFalse(str.isEmpty)
    }

    func testToStringIntervalEmptyForInvalidDates() {
        let event = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "bad",
            end: "data"
        )
        XCTAssertEqual(event.toStringInterval, "")
    }

    // MARK: - Hashable conformance

    func testEventHashable() {
        let event1 = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "2025-01-01",
            end: "2025-01-02"
        )
        let event2 = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            start: "2025-01-01",
            end: "2025-01-02"
        )
        XCTAssertEqual(event1, event2)

        let set: Set<IPNScheduleEvent> = [event1, event2]
        XCTAssertEqual(set.count, 1)
    }

    // MARK: - Missing fields

    func testDecodeEventMissingFieldThrows() {
        let json = """
        { "event_name": "Incompleto", "event_type": "vacations" }
        """
        XCTAssertThrowsError(
            try JSONDecoder().decode(IPNScheduleEvent.self, from: json.data(using: .utf8)!)
        )
    }
}
