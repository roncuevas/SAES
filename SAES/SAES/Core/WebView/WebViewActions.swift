import Foundation
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()
    private init() {}
    
    private let webViewManager = WebViewManager.shared
    private let webViewMessageHandler = WebViewHandler.shared
    
    func loginForm(boleta: String,
                   password: String,
                   captchaText: String) {
        let jsCode = JScriptCode.loginForm(boleta, password, captchaText).value
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "loginForm",
                             javaScript: jsCode,
                             iterations: 1)
        ])
    }
    
    func personalData() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "personalData",
                             url: URLConstants.personalData.value,
                             javaScript: JScriptCode.personalData.value,
                             iterations: 15,
                             condition: { self.webViewMessageHandler.name.isEmpty }),
            DataFetchRequest(id: "getProfileImage",
                             javaScript: JScriptCode.getProfileImage.value,
                             iterations: 15,
                             condition: { self.webViewMessageHandler.profileImageData.isEmptyOrNil })
        ])
    }
    
    func isLoggedAndIsErrorCaptcha() {
        WebViewManager.shared.fetcher.debugTaskManager()
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "isLogged",
                             javaScript: JScriptCode.isLogged.value,
                             verbose: false,
                             condition: { true }),
            DataFetchRequest(id: "isErrorPage",
                             javaScript: JScriptCode.isErrorPage.value,
                             verbose: false,
                             condition: { true })
        ], for: URLConstants.base.value)
    }
    
    func schedule() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "schedule",
                             url: URLConstants.schedule.value,
                             javaScript: JScriptCode.schedule.value,
                             iterations: 15,
                             condition: { self.webViewMessageHandler.schedule.isEmpty })
        ])
    }
    
    func grades() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "grades",
                             url: URLConstants.grades.value,
                             javaScript: JScriptCode.grades.value,
                             iterations: 15,
                             condition: { self.webViewMessageHandler.grades.isEmpty })
        ])
    }
    
    func kardex() {
        webViewMessageHandler.kardex.1 = nil
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "kardex",
                             url: URLConstants.kardex.value,
                             javaScript: JScriptCode.kardex.value,
                             iterations: 15,
                             condition: { self.webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true })
        ])
    }
    
    func captcha() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "reloadCaptcha",
                javaScript: JScriptCode.reloadCaptcha.value,
                iterations: 1),
            DataFetchRequest(
                id: "getCaptchaImage",
                javaScript: JScriptCode.getCaptchaImage.value,
                verbose: false) {
                    self.webViewMessageHandler.imageData.isEmptyOrNil
                }
        ], for: URLConstants.base.value)
    }
    
    func cancelOtherFetchs() {
        WebViewManager.shared.fetcher.cancellTasks(["kardex",
                                                    "getProfileImage",
                                                    "personalData",
                                                    "schedule",
                                                    "grades"])
    }
}
