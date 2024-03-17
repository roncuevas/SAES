import Foundation

struct CookieStorage: Codable {
    let cookies: [UserDefaultsCookie]?
    
    static func getCookies() -> CookieStorage? {
        let data = UserDefaults.standard.data(forKey: "cookies")
        guard let data = data else { return nil }
        let cookies = try? JSONDecoder().decode(CookieStorage.self, from: data)
        return cookies
    }
    
    static func removeCookies() {
        UserDefaults.standard.removeObject(forKey: "cookies")
    }
}
