import Foundation
import WebKit
import RealmSwift

class WebViewManager: ObservableObject {
    
    static let shared: WebViewManager = WebViewManager()
    
    let webView: WKWebView
    private let userContentController: WKUserContentController = WKUserContentController()
    private let coordinator: WebViewCoordinator = WebViewCoordinator.shared
    private let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    let handler: MessageHandler = MessageHandler()
    
    private init() {
        userContentController.add(handler, name: "myNativeApp")
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        webView.navigationDelegate = coordinator
    }
    
    func loadURL(url: URLConstants, cookies: List<CookieModel>? = nil) {
        guard let url = URL(string: url.value) else { return }
        debugPrint("LOADING URL: \(url)")
        let request = URLRequest(url: url)
        if let cookies = cookies {
            for cookie in cookies {
                guard let httpCookie = cookie.toHTTPCookie() else { continue }
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie)
            }
        }
        webView.load(request)
    }
    
    func executeJS(_ javascript: JScriptCode) {
        webView.evaluateJavaScript(JScriptCode.common.rawValue)
        webView.evaluateJavaScript(javascript.rawValue)
    }
}
