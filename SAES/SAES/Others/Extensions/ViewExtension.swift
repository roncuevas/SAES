import SwiftUI
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

    func errorLoadingAlert(isPresented: Binding<Bool>) -> some View {
        modifier(ErrorLoadingPageAlertModifier(isPresented: isPresented))
    }

    func webViewToolbar() -> some View {
        modifier(DebugToolbarModifier {
            WebViewReader { proxy in
                WebView(proxy: proxy)
                    .frame(height: 500)
            }
        })
    }

    func logoutToolbar() -> some View {
        modifier(LogoutToolbarViewModifier())
    }

    func schoolSelectorToolbar() -> some View {
        modifier(SchoolSelectorModifier())
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
