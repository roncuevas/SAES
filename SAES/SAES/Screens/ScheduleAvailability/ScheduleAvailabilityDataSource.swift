import Foundation

final class ScheduleAvailabilityDataSource: SAESDataSource {
    func fetch() async throws -> Data {
        guard let url = URL(string: URLConstants.scheduleAvailability.value)
        else { throw URLError(.badURL) }
        return try await SAESFetcher(url: url)
    }

    func send(states: [SAESViewStates: String],
              values: [ScheduleAvailabilityField: String]) async throws -> Data {
        guard let url = URL(string: URLConstants.scheduleAvailability.value)
        else { throw URLError(.badURL) }
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(cookies, forHTTPHeaderField: AppConstants.HTTPHeaders.cookie)
        var bodyParameters: [String] = []
        states.forEach { (key: SAESViewStates, value: String) in
            let text = "\(key.rawValue)=\(value)"
            bodyParameters.append(text)
        }
        values.forEach { (key: ScheduleAvailabilityField, value: String) in
            let text = "\(key.name)=\(value)"
            bodyParameters.append(text)
        }
        request.httpBody = formURLEncode(bodyParameters.joined(separator: "&"))
            .data(using: .utf8)

        return try await URLSession.shared.data(for: request).0
    }

    func formURLEncode(_ query: String) -> String {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*")
        
        return query
            .split(separator: "&")
            .map { pair -> String in
                let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
                let key = parts.first ?? ""
                let value = parts.count > 1 ? parts[1] : ""

                let encodedKey = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                let encodedValue = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value

                // Convertir %20 en "+"
                let fixedValue = encodedValue.replacingOccurrences(of: "%20", with: "+")
                return "\(encodedKey)=\(fixedValue)"
            }
            .joined(separator: "&")
    }
}
