import Foundation

struct JavaScriptConstants {
    private static let logger = Logger(logLevel: .error)

    private static let bridgeConfig: WebViewBridgeConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(WebViewBridgeConfiguration.self, from: "webview_bridge")
    }()

    static var getCaptchaImage: String { bridgeConfig.jsFunctions["getCaptchaImage"] ?? "" }
    static var getProfileImage: String { bridgeConfig.jsFunctions["getProfileImage"] ?? "" }
    static var reloadCaptcha: String { bridgeConfig.jsFunctions["reloadCaptcha"] ?? "" }
    static var personalData: String { bridgeConfig.jsFunctions["personalData"] ?? "" }
    static var isErrorPage: String { bridgeConfig.jsFunctions["isErrorPage"] ?? "" }
    static var schedule: String { bridgeConfig.jsFunctions["schedule"] ?? "" }
    static var grades: String { bridgeConfig.jsFunctions["grades"] ?? "" }
    static var kardex: String { bridgeConfig.jsFunctions["kardex"] ?? "" }

    static func loginForm(boleta: String, password: String, captcha: String) -> String {
        let template = bridgeConfig.jsFunctions["loginFormTemplate"] ?? ""
        return template
            .replacingOccurrences(of: "{boleta}", with: boleta)
            .replacingOccurrences(of: "{password}", with: password)
            .replacingOccurrences(of: "{captcha}", with: captcha)
    }

    static func downloadRemoteJS() async -> String {
        do {
            let url = URL(
                string: URLConstants.scraperJS
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

    static func loadBundledJS() -> String {
        guard
            let path = Bundle.main.path(
                forResource: "ipn_scrapper",
                ofType: "js"
            ),
            let data = FileManager.default.contents(atPath: path)
        else { return "" }

        return String(data: data, encoding: .utf8) ?? ""
    }
}
