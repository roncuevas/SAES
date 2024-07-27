import Foundation
import RealmSwift
import WebKit

class WebViewCoordinator: NSObject, ObservableObject, WKNavigationDelegate {
    
    static let shared: WebViewCoordinator = WebViewCoordinator()
    
    private override init() {}
    
    @Published var pageLoaded: Bool = false
    @Published var cookies: [HTTPCookie] = []
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        pageLoaded = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pageLoaded = true
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            self.cookies = cookies
        }
    }
}
