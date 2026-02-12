import Foundation
import LocalJSON

enum AvailableSchoolsService {
    private static let nsURL = "https://api.roncuevas.com/saes/ns"
    private static let nmsURL = "https://api.roncuevas.com/saes/nms"
    private static let storage = CachedLocalJSON(
        wrapping: LocalJSON(),
        policy: CachePolicy(ttl: 86400)
    )

    static func fetchSchools(_ type: SchoolType) async -> [AvailableSchool] {
        let (urlString, filename) = switch type {
        case .univeristy: (nsURL, "available_schools_ns.json")
        case .highSchool: (nmsURL, "available_schools_nms.json")
        }

        if let cached = try? storage.getJSON(from: filename, as: CachedSchoolsWrapper.self),
           Date().timeIntervalSince(cached.fetchedAt) < 86400 {
            return cached.schools
        }

        guard let url = URL(string: urlString) else { return [] }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let schools = try JSONDecoder().decode([AvailableSchool].self, from: data)
            let wrapper = CachedSchoolsWrapper(schools: schools, fetchedAt: Date())
            try? storage.writeJSON(data: wrapper, to: filename)
            return schools
        } catch {
            return []
        }
    }
}

private struct CachedSchoolsWrapper: Codable {
    let schools: [AvailableSchool]
    let fetchedAt: Date
}
