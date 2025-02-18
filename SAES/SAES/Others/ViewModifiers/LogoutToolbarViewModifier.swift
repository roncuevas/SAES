import SwiftUI
import Routing
import WebViewAMC

struct LogoutToolbarViewModifier: ViewModifier {
    @AppStorage("isLogged") private var isLogged: Bool = false
    @AppStorage("boleta") private var boleta: String = ""
    @EnvironmentObject private var router: Router<NavigationRoutes>
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
                            webViewManager.webView.injectJavaScript(handlerName: WebViewManager.handlerName,
                                                                    javaScript: JScriptCode.logout.value)
                            do {
                                try await Task.sleep(nanoseconds: 500_000_000)
                                isLogged = false
                                // TODO: Clear cookies for that specific user
                                router.navigateBack()
                            } catch {
                                debugPrint(error)
                            }
                        }
                    } label: {
                        Image(systemName: "door.right.hand.open")
                            .fontWeight(.bold)
                            .tint(.saesColorRed)
                    }
                }
            }
    }
}

extension View {
    func logoutToolbar(webViewManager: WebViewManager) -> some View {
        modifier(LogoutToolbarViewModifier(webViewManager: webViewManager))
    }
}
