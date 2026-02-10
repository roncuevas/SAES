import Foundation

struct UniversityConstants {
    private static let config: SchoolsConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(SchoolsConfiguration.self, from: "schools")
    }()

    static var schools: [SchoolCodes: SchoolData] {
        config.toSchoolDataDictionary(config.universities)
    }

    static var allSchoolsData: [SchoolData] {
        Array(schools.values)
    }
}
