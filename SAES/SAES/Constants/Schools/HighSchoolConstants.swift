import Foundation

struct HighSchoolConstants {
    private static let config = SchoolsConfiguration.shared

    static var schools: [SchoolCodes: SchoolData] {
        config.toSchoolDataDictionary(config.highSchools)
    }

    static var allSchoolsData: [SchoolData] {
        Array(schools.values)
    }
}
