import SwiftUI
import Navigation
import WebViewAMC

struct ErrorLoadingPageAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let webViewManager: WebViewManager
    
    func body(content: Content) -> some View {
        content
            .alert(Localization.error, isPresented: $isPresented) {
                Button(Localization.okey) {
                    webViewManager.webView.loadURL(id: "errorReload", url: URLConstants.standard.value)
                }
            }
    }
}
