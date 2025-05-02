import Routing
import SwiftUI
import WebViewAMC

struct MenuViewModifier: ViewModifier {
    @State var debug: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var router: Router<NavigationRoutes>
    let elements: [MenuElement]

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        buttons
                    } label: {
                        Label("Menu", systemImage: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $debug) {
                WebView(webView: WebViewManager.shared.webView)
                    .frame(height: 500)
            }
    }

    private var buttons: some View {
        ForEach(elements, id: \.self) { item in
            switch item {
            case .news:
                newsButton
            case .ipnSchedule:
                ipnSchedule
            case .debug:
                debugWebViewButton
            case .feedback:
                feedbackButtons
            case .rateApp:
                rateAppButton
            case .logout:
                logoutButton
            }
        }
    }

    private var newsButton: some View {
        Button {
            router.navigate(to: .news)
        } label: {
            Label(Localization.news, systemImage: "newspaper.fill")
                .tint(.saes)
        }
    }

    private var ipnSchedule: some View {
        Button {
            router.navigate(to: .ipnSchedule)
        } label: {
            Label(Localization.ipnSchedule, systemImage: "calendar.and.person")
                .tint(.saes)
        }
    }

    private var logoutButton: some View {
        Button {
            Task {
                do {
                    WebViewActions.shared.cancelOtherFetchs(
                        id: "logoutToolbarViewModifier"
                    )
                    WebViewManager.shared.webView.removeCookies([
                        ".ASPXFORMSAUTH"
                    ])
                    try await Task.sleep(nanoseconds: 500_000_000)
                    WebViewManager.shared.webView.loadURL(
                        id: "logout",
                        url: URLConstants.home.value
                    )
                } catch {
                    print(error.localizedDescription)
                }
            }
        } label: {
            Label(Localization.logout, systemImage: "door.right.hand.open")
                .fontWeight(.bold)
                .tint(.saes)
        }
    }

    private var debugWebViewButton: some View {
        #if DEBUG
            Button {
                debug.toggle()
            } label: {
                Label(Localization.debug, systemImage: "ladybug.fill")
            }
        #else
            EmptyView()
        #endif
    }

    private var feedbackButtons: some View {
        Menu {
            linkButton(
                Localization.sendFeedback,
                icon: "bubble.and.pencil.rtl",
                url:
                    "https://forms.gle/9GP2Mc74urEP54vz9"
            )
            .tint(.saes)
            linkButton(
                Localization.joinBeta,
                icon: "testtube.2",
                url:
                    "https://testflight.apple.com/join/chRbe5EF"
            )
            .tint(.blue)
            linkButton(
                Localization.writeAReview,
                icon: "star.bubble.fill",
                url:
                    "https://apps.apple.com/app/id6467482580?action=write-review"
            )
            .tint(.yellow)
        } label: {
            Label(Localization.feedbackAndSupport, systemImage: "envelope")
                .tint(.saes)
        }
    }

    private var rateAppButton: some View {
        Button {
            requestReview()
        } label: {
            Label(Localization.rateOurApp, systemImage: "star.circle.fill")
                .tint(.yellow)
        }
    }

    private func linkButton(_ title: String, icon: String, url: String)
        -> some View
    {
        Button {
            guard
                let url = URL(
                    string: url
                )
            else { return }
            openURL(url)
        } label: {
            Label(
                title,
                systemImage: icon
            )
        }
    }
}
