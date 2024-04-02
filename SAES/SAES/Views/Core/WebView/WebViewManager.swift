import Foundation
import WebKit

class WebViewManager: ObservableObject {
    
    static let shared: WebViewManager = WebViewManager()
    
    let webView: WKWebView
    private let userContentController: WKUserContentController = WKUserContentController()
    private let coordinator: Coordinator = Coordinator()
    private let configuration: WKWebViewConfiguration = WKWebViewConfiguration()
    let handler: MessageHandler = MessageHandler()
    
    private init() {
        userContentController.add(handler, name: "myNativeApp")
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isInspectable = true
        webView.navigationDelegate = coordinator
    }
    
    func loadURL(url: String, cookies: CookieStorage? = nil) {
        guard let url = URL(string: url) else { return }
        debugPrint("LOADING URL: \(url)")
        let request = URLRequest(url: url)
        if let cookies = cookies?.cookies {
            for cookie in cookies {
                guard let httpCookie = cookie.getHTTPCookie() else { continue }
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie)
            }
        }
        webView.load(request)
    }
    
    func executeJS(_ javascript: JScriptCode) {
        webView.evaluateJavaScript(JScriptCode.common.rawValue)
        webView.evaluateJavaScript(javascript.rawValue)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                let encoded = try? JSONEncoder().encode(CookieStorage(cookies: cookies.getDefaultsFormat()))
                UserDefaults.standard.setValue(encoded, forKey: "cookies")
            }
        }
    }
}
