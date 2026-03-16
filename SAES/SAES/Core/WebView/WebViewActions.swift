import Foundation
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()

    private let proxy: WebViewProxy
    private let webViewMessageHandler = WebViewHandler.shared
    private let logger = Logger(logLevel: .error)
    private static let detectionStrings = DetectionStringsConfiguration.shared

    private init(proxy: WebViewProxy? = nil) {
        self.proxy = proxy ?? WebViewProxy()
    }

    func isStillLogged() async -> Bool {
        guard let academicURL = URL(string: URLConstants.academic.value) else { return false }
        var request = URLRequest(url: academicURL)
        let cookies = await UserSessionManager.shared.cookiesString()
        request.setValue(cookies, forHTTPHeaderField: AppConstants.HTTPHeaders.cookie)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let content = String(data: data, encoding: .utf8)
            let result = !(content?.contains(Self.detectionStrings.loggedInCheck) ?? true)
            logger.log(level: .info, message: "isStillLogged: \(result)", source: "WebViewActions")
            return result
        } catch {
            logger.log(level: .error, message: "\(error)", source: "WebViewActions")
        }
        return false
    }

    func loginForm(
        boleta: String,
        password: String,
        captchaText: String
    ) {
        let jsCode = JScriptCode.loginForm(boleta, password, captchaText).value
        logger.log(level: .info, message: "JS de login inyectado (length: \(jsCode.count))", source: "WebViewActions")
        Task {
            _ = await proxy.fetch(
                .once(id: "loginForm", javaScript: jsCode)
            )
        }
    }

    func isErrorPage() {
        proxy.fetcher.debugTaskManager()
        Task {
            _ = await proxy.fetch(
                .continuous(
                    id: "isErrorPage",
                    url: URLConstants.standard.value,
                    javaScript: JScriptCode.isErrorPage.value,
                    while: { true }
                )
            )
        }
    }

    func getCaptcha() {
        logger.log(level: .info, message: "Fetch de captcha iniciado", source: "WebViewActions")
        Task {
            _ = await proxy.fetch(
                .continuous(
                    id: "getCaptchaImage",
                    url: URLConstants.standard.value,
                    javaScript: JScriptCode.getCaptchaImage.value,
                    while: { self.webViewMessageHandler.imageData.isEmptyOrNil }
                )
            )
        }
    }

    func reloadCaptcha() {
        logger.log(level: .info, message: "Recarga de captcha", source: "WebViewActions")
        Task {
            _ = await proxy.fetch(
                .once(
                    id: "reloadCaptcha",
                    url: URLConstants.standard.value,
                    javaScript: JScriptCode.reloadCaptcha.value
                )
            )
        }
    }

    func cancelOtherFetchs(id: String) {
        let tasks = [
            "getProfileImage",
            "personalData",
            "grades",
            "getCaptchaImage"
        ].filter { !$0.contains(id) }
        proxy.fetcher.cancelTasks(tasks)
    }
}
