import Foundation
import UIKit
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()
    private init() {}
    
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
                             iterations: 5,
                             condition: { !self.webViewMessageHandler.personalData.isEmpty })
        ])
    }
    
    func isErrorPage() {
        WebViewManager.shared.fetcher.debugTaskManager()
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "isErrorPage",
                             javaScript: JScriptCode.isErrorPage.value,
                             verbose: false,
                             condition: { true })
        ], for: URLConstants.standard.value)
    }
    
    func schedule() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "schedule",
                             url: URLConstants.schedule.value,
                             javaScript: JScriptCode.schedule.value,
                             iterations: 5,
                             condition: { self.webViewMessageHandler.schedule.isEmpty })
        ])
    }
    
    func grades() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "grades",
                             url: URLConstants.grades.value,
                             javaScript: JScriptCode.grades.value,
                             iterations: 5,
                             condition: { self.webViewMessageHandler.grades.isEmpty })
        ])
    }
    
    func kardex() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "kardex",
                             url: URLConstants.kardex.value,
                             javaScript: JScriptCode.kardex.value,
                             iterations: 5,
                             condition: { self.webViewMessageHandler.kardex.1?.kardex?.isEmpty ?? true })
        ])
    }
    
    func getCaptcha() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "getCaptchaImage",
                javaScript: JScriptCode.getCaptchaImage.value,
                verbose: false) {
                    self.webViewMessageHandler.imageData.isEmptyOrNil
                }
        ], for: URLConstants.standard.value)
    }
    
    func reloadCaptcha() {
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "reloadCaptcha",
                javaScript: JScriptCode.reloadCaptcha.value,
                iterations: 1)
        ], for: URLConstants.standard.value)
    }
    
    func cancelOtherFetchs() {
        WebViewManager.shared.fetcher.cancellTasks(["kardex",
                                                    "getProfileImage",
                                                    "personalData",
                                                    "schedule",
                                                    "grades",
                                                    "getCaptchaImage"])
    }
    
    func getProfileImage() {
        let imageUrl = URL(string: URLConstants.personalPhoto.value)!
        var request = URLRequest(url: imageUrl)
        
        if let cookies = HTTPCookieStorage.shared.cookies(for: URL(string: "https://www.saes.escom.ipn.mx/")!) {
            let cookieHeader = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            request.setValue(cookieHeader, forHTTPHeaderField: "Cookie")
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data,
                let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.webViewMessageHandler.profileImage = uiImage
                }
            } else {
                print("Error al cargar la imagen:", error.debugDescription)
            }
        }.resume()
    }
}
