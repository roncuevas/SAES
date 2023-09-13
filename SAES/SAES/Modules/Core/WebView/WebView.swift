import SwiftUI
import Foundation
import WebKit

struct WebView: UIViewRepresentable {
    
    @Binding var webView: WKWebView
    var url: String
    var cookies: [HTTPCookie]?
    
    func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: url) else { return webView }
        var request = URLRequest(url: url)
        dump(cookies)
        if let cookies = cookies {
            for cookie in cookies {
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            }
            request.allHTTPHeaderFields = HTTPCookie.requestHeaderFields(with: cookies)
        }
        request.httpShouldHandleCookies = true
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator
    }
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                dump(cookies)
                /*
                let encoded = JSONEncoder().encode(CookieStorage(cookies: cookies.getDefaultsFormat()))
                UserDefaults.standard.setValue(encoded, forKey: "cookies")
                 */
            }
        }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        @State var webView = WKWebView()
        WebView(webView: $webView, url: "www.google.com")
    }
}
