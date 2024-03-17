import Foundation

extension UserDefaults {
    func setJSON(json: [String: String], forKey: String) {
        let jsonEncoded = try? JSONEncoder().encode(json)
        setValue(jsonEncoded, forKey: forKey)
    }
}
