import Foundation
import UIKit
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()
    private init() {}

    private let webViewMessageHandler = WebViewHandler.shared
    private let logger = Logger(logLevel: .error)
    private static let detectionStrings: DetectionStringsConfiguration = {
        // swiftlint:disable:next force_try
        try! ConfigurationLoader.shared.load(DetectionStringsConfiguration.self, from: "detection_strings")
    }()

    func isStillLogged() async -> Bool {
        guard let academicURL = URL(string: URLConstants.academic.value) else { return false }
        var request = URLRequest(url: academicURL)
        let cookies = await UserSessionManager.shared.cookiesString()
        request.setValue(cookies, forHTTPHeaderField: AppConstants.HTTPHeaders.cookie)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let content = String(data: data, encoding: .utf8)
            return !(content?.contains(Self.detectionStrings.loggedInCheck) ?? true)
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
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .once(id: "loginForm", javaScript: jsCode)
            )
        }
    }

    func personalData() {
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .poll(
                    id: "personalData",
                    url: URLConstants.personalData.value,
                    javaScript: JScriptCode.personalData.value,
                    maxAttempts: 5,
                    until: { !self.webViewMessageHandler.personalData.isEmpty }
                )
            )
        }
    }

    func isErrorPage() {
        WebViewManager.shared.fetcher.debugTaskManager()
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .continuous(
                    id: "isErrorPage",
                    url: URLConstants.standard.value,
                    javaScript: JScriptCode.isErrorPage.value,
                    while: { true }
                )
            )
        }
    }

    func schedule() {
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .poll(
                    id: "schedule",
                    url: URLConstants.schedule.value,
                    javaScript: JScriptCode.schedule.value,
                    maxAttempts: 5,
                    until: { !self.webViewMessageHandler.schedule.isEmpty }
                )
            )
        }
    }

    func grades() {
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .poll(
                    id: "grades",
                    url: URLConstants.grades.value,
                    javaScript: JScriptCode.grades.value,
                    maxAttempts: 5,
                    until: { !self.webViewMessageHandler.grades.isEmpty }
                )
            )
        }
    }

    func kardex() {
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
                .poll(
                    id: "kardex",
                    url: URLConstants.kardex.value,
                    javaScript: JScriptCode.kardex.value,
                    maxAttempts: 5,
                    until: {
                        !(self.webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true)
                    }
                )
            )
        }
    }

    func getCaptcha() {
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
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
        Task {
            _ = await WebViewManager.shared.fetcher.fetch(
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
            "kardex",
            "getProfileImage",
            "personalData",
            "schedule",
            "grades",
            "getCaptchaImage"
        ].filter { !$0.contains(id) }
        WebViewManager.shared.fetcher.cancelTasks(tasks)
    }
}
