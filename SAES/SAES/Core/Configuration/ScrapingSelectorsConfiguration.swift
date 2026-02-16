import Foundation

struct ScrapingSelectorsConfiguration: Decodable {
    let grades: GradesSelectors
    let schedule: ScheduleSelectors
    let kardex: KardexSelectors
    let scheduleAvailability: ScheduleAvailabilitySelectors

    struct ScheduleSelectors: Decodable {
        let tableIDs: [String]
    }

    struct KardexSelectors: Decodable {
        let panelIDs: [String]
        let carreraIDs: [String]
        let planIDs: [String]
        let promedioIDs: [String]
        let semesterTablesSelector: String
    }

    struct GradesSelectors: Decodable {
        let tableIDs: [String]
        let evaluationTableIDs: [String]
        let expectedColumnCount: Int
        let columnMapping: [String: Int]
        let acceptButtonIDs: [String]
    }

    struct ScheduleAvailabilitySelectors: Decodable {
        let tableSelector: String
        let expectedColumnCount: Int
        let columnMapping: [String: Int]
        let fields: [String: FieldSelector]
    }

    struct FieldSelector: Decodable {
        let type: String
        let selector: String
        let postName: String
    }
}
