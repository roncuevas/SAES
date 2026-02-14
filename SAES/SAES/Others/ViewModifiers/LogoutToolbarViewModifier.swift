import SwiftUI
import WebViewAMC
import os

struct LogoutToolbarViewModifier: ViewModifier {
    @EnvironmentObject private var proxy: WebViewProxy

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                WebViewActions.shared.cancelOtherFetchs(id: "logoutToolbarViewModifier")
                                await proxy.cookieManager.removeCookies(named: [AppConstants.CookieNames.aspxFormsAuth])
                                try await Task.sleep(for: .seconds(AppConstants.Timing.logoutDelay))
                                proxy.load(URLConstants.home.value)
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
