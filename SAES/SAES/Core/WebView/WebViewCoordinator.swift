import Foundation
import WebKit

class WebViewCoordinator: NSObject, ObservableObject, WKNavigationDelegate {
    
    static let shared: WebViewCoordinator = WebViewCoordinator()
    
    private override init() {}
    
    @Published var pageLoaded: Bool = false
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        pageLoaded = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoaded = true
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            let encoded = try? JSONEncoder().encode(CookieStorage(cookies: cookies.getDefaultsFormat()))
            UserDefaults.standard.setValue(encoded, forKey: "cookies")
        }
    }
}
