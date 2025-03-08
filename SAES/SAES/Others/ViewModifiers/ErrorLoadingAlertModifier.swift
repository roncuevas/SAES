import SwiftUI
import Routing
import WebViewAMC

struct ErrorLoadingPageAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    let webViewManager: WebViewManager
    
    func body(content: Content) -> some View {
        content
            .alert("Error cargando la pagina", isPresented: $isPresented) {
                Button("Ok") {
                    webViewManager.fetcher.fetch([], for: URLConstants.standard.value)
                }
            }
    }
}

extension View {
    func errorLoadingAlert(isPresented: Binding<Bool>, webViewManager: WebViewManager) -> some View {
        modifier(ErrorLoadingPageAlertModifier(isPresented: isPresented, webViewManager: webViewManager))
    }
}
