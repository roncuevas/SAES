import SwiftUI
import WebViewAMC

struct ErrorLoadingPageAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    @EnvironmentObject private var proxy: WebViewProxy

    func body(content: Content) -> some View {
        content
            .alert(Localization.error, isPresented: $isPresented) {
                Button(Localization.okey) {
                    proxy.load(URLConstants.standard.value)
                }
            }
    }
}
