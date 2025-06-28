import Foundation

protocol GradesDataSource {
    func fetchGrades() async throws -> Data
    func fetchEvaluationTeachers() async throws -> Data
}

struct NetworkGradesDataSource: GradesDataSource {
    func fetchGrades() async throws -> Data {
        let url = URL(string: URLConstants.grades.value)
        guard let url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        return try await URLSession.shared.data(for: request).0
    }

    func fetchEvaluationTeachers() async throws -> Data {
        let url = URL(string: URLConstants.evalTeachers.value)
        guard let url else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")
        return try await URLSession.shared.data(for: request).0
    }
}
