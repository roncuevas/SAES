import Foundation
import WebKit

class WebViewManager: ObservableObject {
    
    var webView: WKWebView
    private let userContentController: WKUserContentController = .init()
    private let coordinator: Coordinator = .init()
    private let configuration: WKWebViewConfiguration = .init()
    let handler: MessageHandler = .init()
    
    init() {
        userContentController.add(handler, name: "myNativeApp")
        configuration.userContentController = userContentController
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = coordinator
    }
    
    func loadURL(url: String, cookies: CookieStorage? = nil) {
        guard let url = URL(string: url) else { return }
        let request = URLRequest(url: url)
        if let cookies = cookies?.cookies {
            for cookie in cookies {
                guard let httpCookie = cookie.getHTTPCookie() else { continue }
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(httpCookie)
            }
        }
        webView.load(request)
    }
    
    func executeJS(_ javascript: String) {
        webView.evaluateJavaScript(javascript)
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