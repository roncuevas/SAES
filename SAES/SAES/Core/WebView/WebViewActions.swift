import Foundation
import UIKit
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()
    private init() {}

    private let webViewMessageHandler = WebViewHandler.shared
    private let logger = Logger(logLevel: .error)

    func isStillLogged() async -> Bool {
        guard let academicURL = URL(string: URLConstants.academic.value) else { return false }
        var request = URLRequest(url: academicURL)
        let cookies: String = LocalStorageManager.loadLocalCookies(UserDefaults.schoolCode)
        request.setValue(cookies, forHTTPHeaderField: "Cookie")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let content = String(data: data, encoding: .utf8)
            return !(content?.contains("IPN-SAES") ?? true)
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
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "loginForm",
                javaScript: jsCode,
                iterations: 1
            )
        ])
    }

    func personalData() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "personalData",
                url: URLConstants.personalData.value,
                javaScript: JScriptCode.personalData.value,
                iterations: 5,
                condition: {
                    !self.webViewMessageHandler.personalData.isEmpty
                }
            )
        ])
    }

    func isErrorPage() {
        WebViewManager.shared.fetcher.debugTaskManager()
        WebViewManager.shared.fetcher.fetch(
            [
                DataFetchRequest(
                    id: "isErrorPage",
                    javaScript: JScriptCode.isErrorPage.value,
                    verbose: false,
                    condition: { true }
                )
            ],
            for: URLConstants.standard.value
        )
    }

    func schedule() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "schedule",
                url: URLConstants.schedule.value,
                javaScript: JScriptCode.schedule.value,
                iterations: 5,
                condition: { self.webViewMessageHandler.schedule.isEmpty }
            )
        ])
    }

    func grades() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "grades",
                url: URLConstants.grades.value,
                javaScript: JScriptCode.grades.value,
                iterations: 5,
                condition: { self.webViewMessageHandler.grades.isEmpty }
            )
        ])
    }

    func kardex() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "kardex",
                url: URLConstants.kardex.value,
                javaScript: JScriptCode.kardex.value,
                iterations: 5,
                condition: {
                    self.webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true
                }
            )
        ])
    }

    func getCaptcha() {
        WebViewManager.shared.fetcher.fetch(
            [
                DataFetchRequest(
                    id: "getCaptchaImage",
                    javaScript: JScriptCode.getCaptchaImage.value,
                    verbose: false
                ) {
                    self.webViewMessageHandler.imageData.isEmptyOrNil
                }
            ],
            for: URLConstants.standard.value
        )
    }

    func reloadCaptcha() {
        WebViewManager.shared.fetcher.fetch(
            [
                DataFetchRequest(
                    id: "reloadCaptcha",
                    javaScript: JScriptCode.reloadCaptcha.value,
                    iterations: 1
                )
            ],
            for: URLConstants.standard.value
        )
    }

    func cancelOtherFetchs(id: String) {
        let tasks = [
            "kardex",
            "getProfileImage",
            "personalData",
            "schedule",
            "grades",
            "getCaptchaImage"
        ].filter { !$0.contains(id) }
        WebViewManager.shared.fetcher.cancellTasks(tasks)
    }
}
