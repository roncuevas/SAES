import SwiftUI
import Routing
import WebViewAMC

struct ErrorLoadingPageAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let webViewManager: WebViewManager
    
    func body(content: Content) -> some View {
        content
            .alert(Localization.error, isPresented: $isPresented) {
                Button(Localization.okey) {
                    webViewManager.fetcher.fetch([], for: URLConstants.standard.value)
                }
            }
    }
}
