import Foundation

extension UserDefaults {
    func setJSON(json: Dictionary<String,String>, forKey: String) {
        let jsonEncoded = try? JSONEncoder().encode(json)
        setValue(json, forKey: forKey)
    }
}
