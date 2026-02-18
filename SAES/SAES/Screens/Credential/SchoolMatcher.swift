import Foundation

struct SchoolMatcher {
    static let shared = SchoolMatcher()

    private let byLongName: [(SchoolData, String)]
    private let byName: [(SchoolData, String)]
    private let byCode: [(SchoolData, String)]

    private init() {
        let all = Array(UniversityConstants.schools.values)
            + Array(HighSchoolConstants.schools.values)

        byLongName = all.map { ($0, Self.normalize($0.longName)) }
            .sorted { $0.1.count > $1.1.count }
        byName = all.map { ($0, Self.normalize($0.name)) }
            .sorted { $0.1.count > $1.1.count }
        byCode = all.map { ($0, $0.code.rawValue) }
            .sorted { $0.1.count > $1.1.count }
    }

    func detectSchool(from schoolText: String) -> SchoolData? {
        let normalized = Self.normalize(schoolText)

        for (school, term) in byLongName {
            if normalized.contains(term) { return school }
        }
        for (school, term) in byName {
            if normalized.contains(term) { return school }
        }
        for (school, term) in byCode {
            if normalized.contains(term) { return school }
        }
        return nil
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
}
