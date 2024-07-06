import XCTest
@testable import SAES

final class EventManagerTests: XCTestCase {
    
    func testWeekDays() {
        let weekDays = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
        XCTAssertEqual(weekDays, EventManager.weekDays)
    }
}
