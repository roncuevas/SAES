import XCTest
@testable import SAES

final class IPNScheduleModelTests: XCTestCase {

    // MARK: - IPNScheduleModel

    func testDecodeScheduleModel() throws {
        let json = """
        {
            "year": 2025,
            "month": 3,
            "events": [
                {
                    "event_name": "Vacaciones de Semana Santa",
                    "event_type": "vacations",
                    "range": {
                        "start": "2025-04-14",
                        "end": "2025-04-25"
                    }
                }
            ]
        }
        """
        let model = try JSONDecoder().decode(IPNScheduleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.year, 2025)
        XCTAssertEqual(model.month, 3)
        XCTAssertEqual(model.events.count, 1)
    }

    func testDecodeScheduleModelWithMultipleEvents() throws {
        let json = """
        {
            "year": 2025,
            "month": 5,
            "events": [
                {
                    "event_name": "Primer parcial",
                    "event_type": "ordinary_evaluation",
                    "range": { "start": "2025-05-01", "end": "2025-05-05" }
                },
                {
                    "event_name": "Dia del trabajo",
                    "event_type": "day_off",
                    "range": { "start": "2025-05-01", "end": "2025-05-01" }
                }
            ]
        }
        """
        let model = try JSONDecoder().decode(IPNScheduleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.events.count, 2)
        XCTAssertEqual(model.events[0].name, "Primer parcial")
        XCTAssertEqual(model.events[1].name, "Dia del trabajo")
    }

    func testDecodeScheduleModelWithEmptyEvents() throws {
        let json = """
        { "year": 2025, "month": 7, "events": [] }
        """
        let model = try JSONDecoder().decode(IPNScheduleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.year, 2025)
        XCTAssertEqual(model.month, 7)
        XCTAssertTrue(model.events.isEmpty)
    }

    // MARK: - IPNScheduleResponse (array)

    func testDecodeFullResponse() throws {
        let json = """
        [
            {
                "year": 2025,
                "month": 1,
                "events": [
                    {
                        "event_name": "Inicio de semestre",
                        "event_type": "period_start",
                        "range": { "start": "2025-01-06", "end": "2025-01-06" }
                    }
                ]
            },
            {
                "year": 2025,
                "month": 2,
                "events": []
            }
        ]
        """
        let response = try JSONDecoder().decode(IPNScheduleResponse.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(response.count, 2)
        XCTAssertEqual(response[0].month, 1)
        XCTAssertEqual(response[1].events.count, 0)
    }

    // MARK: - IPNScheduleEvent

    func testDecodeEventCodingKeys() throws {
        let json = """
        {
            "event_name": "Evaluacion extraordinaria",
            "event_type": "extraordinary_evaluation",
            "range": { "start": "2025-06-10", "end": "2025-06-20" }
        }
        """
        let event = try JSONDecoder().decode(IPNScheduleEvent.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(event.name, "Evaluacion extraordinaria")
        XCTAssertEqual(event.type, "extraordinary_evaluation")
        XCTAssertEqual(event.dateRange.start, "2025-06-10")
        XCTAssertEqual(event.dateRange.end, "2025-06-20")
    }

    func testEncodeEventUsesCorrectKeys() throws {
        let event = IPNScheduleEvent(
            name: "Fin de semestre",
            type: "period_end",
            dateRange: IPNDateRange(start: "2025-12-12", end: "2025-12-12")
        )
        let data = try JSONEncoder().encode(event)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return XCTFail("Failed to serialize encoded event")
        }
        XCTAssertNotNil(dict["event_name"])
        XCTAssertNotNil(dict["event_type"])
        XCTAssertNotNil(dict["range"])
        XCTAssertNil(dict["name"])
        XCTAssertNil(dict["type"])
        XCTAssertNil(dict["dateRange"])
    }

    // MARK: - IPNDateRange

    func testDateRangeStartAndEndDates() {
        let range = IPNDateRange(start: "2025-03-15", end: "2025-03-20")
        XCTAssertNotNil(range.startDate)
        XCTAssertNotNil(range.endDate)

        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: range.startDate!)
        XCTAssertEqual(startComponents.year, 2025)
        XCTAssertEqual(startComponents.month, 3)
        XCTAssertEqual(startComponents.day, 15)
    }

    func testDateRangeInvalidDateReturnsNil() {
        let range = IPNDateRange(start: "invalid", end: "also-invalid")
        XCTAssertNil(range.startDate)
        XCTAssertNil(range.endDate)
        XCTAssertNil(range.toDateInterval)
    }

    func testDateRangeToDateInterval() {
        let range = IPNDateRange(start: "2025-01-01", end: "2025-01-31")
        let interval = range.toDateInterval
        XCTAssertNotNil(interval)
        XCTAssertTrue(interval!.duration > 0)
    }

    func testDateRangeToStringIntervalNotEmpty() {
        let range = IPNDateRange(start: "2025-04-14", end: "2025-04-25")
        let str = range.toStringInterval
        XCTAssertFalse(str.isEmpty)
    }

    func testDateRangeToStringIntervalEmptyForInvalidDates() {
        let range = IPNDateRange(start: "bad", end: "data")
        XCTAssertEqual(range.toStringInterval, "")
    }

    // MARK: - Hashable conformance

    func testScheduleModelHashable() {
        let event = IPNScheduleEvent(
            name: "Test",
            type: "vacations",
            dateRange: IPNDateRange(start: "2025-01-01", end: "2025-01-02")
        )
        let model1 = IPNScheduleModel(year: 2025, month: 1, events: [event])
        let model2 = IPNScheduleModel(year: 2025, month: 1, events: [event])
        XCTAssertEqual(model1, model2)

        let set: Set<IPNScheduleModel> = [model1, model2]
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

    func testDecodeModelMissingEventsThrows() {
        let json = """
        { "year": 2025, "month": 1 }
        """
        XCTAssertThrowsError(
            try JSONDecoder().decode(IPNScheduleModel.self, from: json.data(using: .utf8)!)
        )
    }
}
