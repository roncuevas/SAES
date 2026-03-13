import SwiftUI
import WebViewAMC

struct MenuLogoutButton: View {
    private let logger = Logger(logLevel: .error)
    @EnvironmentObject private var proxy: WebViewProxy

    var body: some View {
        Button {
            Task {
                do {
                    WebViewActions.shared.cancelOtherFetchs(
                        id: "logoutToolbarViewModifier"
                    )
                    ScheduleStore.shared.clear()
                    await proxy.cookieManager.removeCookies(named: [
                        AppConstants.CookieNames.aspxFormsAuth
                    ])
                    try await Task.sleep(for: .seconds(AppConstants.Timing.logoutDelay))
                    proxy.load(URLConstants.home.value)
                } catch {
                    logger.log(level: .error, message: "\(error.localizedDescription)", source: "MenuLogoutButton")
                }
            }
        } label: {
            Label(Localization.logout, systemImage: "door.right.hand.open")
                .fontWeight(.bold)
                .tint(.saes)
        }
    }
}
