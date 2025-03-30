import SwiftUI
import WebKit
import WebViewAMC

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func errorLoadingAlert(isPresented: Binding<Bool>, webViewManager: WebViewManager) -> some View {
        modifier(ErrorLoadingPageAlertModifier(isPresented: isPresented, webViewManager: webViewManager))
    }
    
    func webViewToolbar(webView: WKWebView) -> some View {
        modifier(DebugToolbarModifier {
            WebView(webView: webView)
                .frame(height: 500)
        })
    }
    
    func logoutToolbar(webViewManager: WebViewManager) -> some View {
        modifier(LogoutToolbarViewModifier(webViewManager: webViewManager))
    }
    
    func schoolSelectorToolbar(fetcher: WebViewDataFetcher) -> some View {
        modifier(SchoolSelectorModifier(fetcher: fetcher))
    }
}
