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

    func menuToolbar(elements: [MenuElement]) -> some View {
        modifier(MenuViewModifier(elements: elements))
    }

    func navigationBarTitle(title: String,
                            titleDisplayMode: NavigationBarItem.TitleDisplayMode = .automatic,
                            background: Visibility = .automatic,
                            backButtonHidden: Bool = true) -> some View {
        modifier(
            NavigationViewModifier(
                title: title,
                titleDisplayMode: titleDisplayMode,
                background: background,
                backButtonHidden: backButtonHidden
            )
        )
    }
}
