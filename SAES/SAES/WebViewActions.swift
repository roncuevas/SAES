import Foundation
import WebViewAMC

@MainActor
final class WebViewActions {
    static let shared = WebViewActions()
    private init() {}
    
    private let webViewManager = WebViewManager.shared
    
    func loginForm(boleta: String,
                   password: String,
                   captchaText: String) {
        let js = JScriptCode.loginForm(boleta, password, captchaText).value
        print(js)
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(id: "loginForm",
                             javaScript: js,
                             iterations: 1)
        ])
    }
}
