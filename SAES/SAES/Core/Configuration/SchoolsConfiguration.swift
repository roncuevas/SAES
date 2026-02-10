import Foundation

struct SchoolsConfiguration: Decodable {
    let highSchools: [SchoolEntry]
    let universities: [SchoolEntry]

    struct SchoolEntry: Decodable {
        let name: String
        let code: String
        let saesURL: String
        let order: Int
    }

    func toSchoolDataDictionary(_ entries: [SchoolEntry]) -> [SchoolCodes: SchoolData] {
        var dict: [SchoolCodes: SchoolData] = [:]
        for entry in entries {
            guard let code = SchoolCodes(rawValue: entry.code) else { continue }
            dict[code] = SchoolData(name: entry.name, code: code, saes: entry.saesURL, order: entry.order)
        }
        return dict
    }
}
