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
        if let result = match(in: normalized) { return result }

        let cleaned = Self.normalize(Self.cleanSchoolText(schoolText))
        if cleaned != normalized, let result = match(in: cleaned) { return result }

        return nil
    }

    private func match(in text: String) -> SchoolData? {
        for (school, term) in byLongName {
            if text.contains(term) { return school }
        }
        for (school, term) in byName {
            if text.contains(term) { return school }
        }
        for (school, term) in byCode {
            if text.contains(term) { return school }
        }
        return nil
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }

    private static func cleanSchoolText(_ text: String) -> String {
        text.replacingOccurrences(of: "\\([^)]*\\)", with: "", options: .regularExpression)
            .replacingOccurrences(of: ",\\s*Unidad\\b", with: "", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
    }
}
