import FirebaseRemoteConfig
import Navigation
import SwiftUI
import WebViewAMC

struct MenuViewModifier: ViewModifier {
    private let logger = Logger(logLevel: .error)
    @State var debug: Bool = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var proxy: WebViewProxy
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnNewsScreen,
        fallback: true
    ) private var newsEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnScheduleScreen,
        fallback: true
    ) private var ipnScheduleEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.scheduleAvailabilityScreen,
        fallback: true
    ) private var scheduleAvailabilityEnabled
    let elements: [MenuElement]

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        buttons
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $debug) {
                WebView(proxy: proxy)
                    .frame(height: 500)
            }
    }

    private var buttons: some View {
        ForEach(elements, id: \.self) { item in
            switch item {
            case .news:
                if newsEnabled {
                    newsButton
                }
            case .ipnSchedule:
                if ipnScheduleEnabled {
                    ipnSchedule
                }
            case .scheduleAvailability:
                if scheduleAvailabilityEnabled {
                    scheduleAvailability
                }
            case .credential:
                credentialButton
            case .debug:
                debugWebViewButton
            case .feedback:
                feedbackButtons
            case .rateApp:
                rateAppButton
            case .settings:
                settingsButton
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

    private var scheduleAvailability: some View {
        Button {
            router.navigate(to: .scheduleAvailability)
        } label: {
            Label(Localization.scheduleAvailability, systemImage: "chart.bar.horizontal.page.fill")
                .tint(.saes)
        }
    }

    private var credentialButton: some View {
        Button {
            router.navigate(to: .credential)
        } label: {
            Label(Localization.myCredential, systemImage: "person.text.rectangle")
                .tint(.saes)
        }
    }

    private var settingsButton: some View {
        Button {
            router.navigate(to: .settings)
        } label: {
            Label(Localization.settings, systemImage: "gearshape")
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
                    await proxy.cookieManager.removeCookies(named: [
                        AppConstants.CookieNames.aspxFormsAuth
                    ])
                    try await Task.sleep(for: .seconds(AppConstants.Timing.logoutDelay))
                    proxy.load(URLConstants.home.value)
                } catch {
                    logger.log(level: .error, message: "\(error.localizedDescription)", source: "MenuViewModifier")
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
                url: URLConstants.feedbackForm
            )
            .tint(.saes)
            linkButton(
                Localization.joinBeta,
                icon: "testtube.2",
                url: URLConstants.testFlight
            )
            .tint(.blue)
            linkButton(
                Localization.writeAReview,
                icon: "star.bubble.fill",
                url: URLConstants.appStoreReview
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

    private func linkButton(_ title: String, icon: String, url: String) -> some View {
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
