import SwiftUI
import Routing

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
                            webViewManager.executeJS(.logout)
                            do {
                                try await Task.sleep(nanoseconds: 500_000_000)
                                isLogged = false
                                if let user = RealmManager.getUser(for: boleta) {
                                    RealmManager.shared.deleteObject(object: user.cookies)
                                }
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
