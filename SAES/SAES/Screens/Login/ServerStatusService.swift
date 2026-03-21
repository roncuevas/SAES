import Foundation

enum ServerStatusService {
    private static var nsBaseURL: String { URLConstants.saesStatusNS }
    private static var nmsBaseURL: String { URLConstants.saesStatusNMS }

    static func fetchAllStatuses(for type: SchoolType) async -> [String: Bool] {
        let urlString = type == .highSchool ? nmsBaseURL : nsBaseURL
        guard let url = URL(string: urlString) else { return [:] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let statuses = try JSONDecoder().decode([ServerStatus].self, from: data)
            return Dictionary(uniqueKeysWithValues: statuses.map { ($0.schoolCode, $0.isOnline) })
        } catch {
            return [:]
        }
    }

    static func fetchStatus(for schoolCode: String) async -> Bool? {
        let code = SchoolCodes(rawValue: schoolCode)
        let isHighSchool = code.map { HighSchoolConstants.schools[$0] != nil } ?? false
        let urlString = isHighSchool ? nmsBaseURL : nsBaseURL

        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let statuses = try JSONDecoder().decode([ServerStatus].self, from: data)
            return statuses.first(where: { $0.schoolCode == schoolCode })?.isOnline
        } catch {
            return nil
        }
    }
}
