import Foundation
import RealmSwift
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
            let userSession = RealmManager.shared.getObjects(type: UserSessionModel.self)?.where { $0.school.contains(UserDefaults.standard.getSchoolCode()) }
            guard let userSession = userSession?.first else { return }
            RealmManager.shared.deleteObject(object: userSession.cookies)
            RealmManager.shared.updateObject {
                cookies.forEach { userSession.cookies.append($0.getDefaultsFormat()) }
            }
        }
    }
}
