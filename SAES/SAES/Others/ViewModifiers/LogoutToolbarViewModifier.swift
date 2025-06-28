import SwiftUI
import Routing
import WebViewAMC
import os

struct LogoutToolbarViewModifier: ViewModifier {
    private let webViewManager: WebViewManager
    
    init(webViewManager: WebViewManager) {
        self.webViewManager = webViewManager
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                WebViewActions.shared.cancelOtherFetchs(id: "logoutToolbarViewModifier")
                                webViewManager.webView.removeCookies([".ASPXFORMSAUTH"])
                                try await Task.sleep(nanoseconds: 500_000_000)
                                webViewManager.webView.loadURL(id: "logout", url: URLConstants.home.value)
                            } catch {
                                Logger().log(
                                    level: .error,
                                    message: "\(error.localizedDescription)",
                                    metadata: nil,
                                    source: "LogoutToolbarViewModifier"
                                )
                            }
                        }
                    } label: {
                        Label(Localization.logout, systemImage: "door.right.hand.open")
                            .fontWeight(.bold)
                            .tint(.saes)
                    }
                }
            }
    }
}
