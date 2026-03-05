import Foundation

struct UniversityConstants {
    private static let config = SchoolsConfiguration.shared

    static var schools: [SchoolCodes: SchoolData] {
        config.toSchoolDataDictionary(config.universities)
    }

    static var allSchoolsData: [SchoolData] {
        Array(schools.values)
    }
}
