import Foundation

struct JavaScriptConstants {
    private static let logger = Logger(logLevel: .error)

    static let getCaptchaImage = "window.SAES.getCaptchaImage();"
    static let getProfileImage = "window.SAES.getProfileImage();"
    static let reloadCaptcha = "window.SAES.reloadCaptcha();"
    static let personalData = "window.SAES.extractPersonalData();"
    static let isErrorPage = "window.SAES.checkErrorPage();"
    static let schedule = "window.SAES.extractSchedule();"
    static let grades = "window.SAES.extractGrades();"
    static let kardex = "window.SAES.extractKardex();"

    static func loginForm(boleta: String, password: String, captcha: String) -> String {
        """
        window.SAES.fillLoginForm("\(boleta)", "\(password)", "\(captcha)");
        """
    }

    static func getCommonJS() async -> String {
        do {
            let url = URL(
                string: "https://api.roncuevas.com/files/ipn_scrapper_encrypted.js"
            )!
            var request = URLRequest(url: url)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            logger.log(level: .error, message: "Error loading script: \(error)", source: "JavaScriptConstants")
            return ""
        }
    }

    static func loadCommonJS() -> String {
        guard
            let path = Bundle.main.path(
                forResource: "ipn_scrapper_encrypted",
                ofType: "js"
            ),
            let data = FileManager.default.contents(atPath: path)
        else { return "" }

        return String(data: data, encoding: .utf8) ?? ""
    }
}
