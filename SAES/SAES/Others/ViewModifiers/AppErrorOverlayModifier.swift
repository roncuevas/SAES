import SwiftUI
import WebViewAMC

struct AppErrorOverlayModifier: ViewModifier {
    let isDataLoaded: Bool
    @EnvironmentObject private var webViewHandler: WebViewHandler
    @EnvironmentObject private var proxy: WebViewProxy

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                if let error = webViewHandler.appError,
                   error == .sessionExpired || !isDataLoaded {
                    ErrorStateView(errorType: error, action: action(for: error))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.background)
                }
            }
    }

    private func action(for error: SAESErrorType) -> () -> Void {
        switch error {
        case .noInternet, .serverError:
            return {
                webViewHandler.retryError()
                proxy.load(URLConstants.standard.value)
            }
        case .sessionExpired:
            return { webViewHandler.dismissSessionExpired() }
        }
    }
}
