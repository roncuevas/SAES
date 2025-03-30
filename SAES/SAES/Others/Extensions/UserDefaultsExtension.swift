import Foundation

extension UserDefaults {
    
    static var schoolCode: String {
        return UserDefaults.standard.string(forKey: "schoolCode") ?? ""
    }
    
    /*
    func setJSON(json: [String: String], forKey: String) {
        let jsonEncoded = try? JSONEncoder().encode(json)
        setValue(jsonEncoded, forKey: forKey)
    }
     */
}
