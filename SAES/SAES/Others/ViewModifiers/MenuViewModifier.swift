@preconcurrency import FirebaseRemoteConfig
import SwiftUI
import WebViewAMC

struct MenuViewModifier: ViewModifier {
    private let logger = Logger(logLevel: .error)
    @State private var debug = false
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var proxy: WebViewProxy
    @ObservedObject private var scheduleReceiptManager = ScheduleReceiptManager.shared
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
    let items: [MenuItem]

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        menuContent
                    } label: {
                        Label("Menu", systemImage: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $debug) {
                WebView(proxy: proxy)
                    .frame(height: 500)
            }
            .quickLookPreview($scheduleReceiptManager.pdfURL)
    }

    // MARK: - Menu rendering

    private var menuContent: some View {
        ForEach(items) { item in
            renderItem(item)
        }
    }

    @ViewBuilder
    private func renderItem(_ item: MenuItem) -> some View {
        switch item {
        case .element(let element):
            if isVisible(element) {
                renderElement(element)
            }
        case .submenu(_, let title, let icon, let children):
            let visibleChildren = children.filter { isVisible($0) }
            if !visibleChildren.isEmpty {
                Menu {
                    ForEach(visibleChildren, id: \.self) { child in
                        renderElement(child)
                    }
                } label: {
                    Label(title, systemImage: icon)
                        .tint(.saes)
                }
            }
        }
    }

    // MARK: - Visibility

    private func isVisible(_ element: MenuElement) -> Bool {
        switch element {
        case .news: return newsEnabled
        case .ipnSchedule: return ipnScheduleEnabled
        case .scheduleAvailability: return scheduleAvailabilityEnabled
        case .scheduleReceipt: return scheduleReceiptManager.hasCachedPDF
        case .debug: return isDebugMode
        default: return true
        }
    }

    private var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    // MARK: - Element buttons

    @ViewBuilder
    private func renderElement(_ element: MenuElement) -> some View {
        switch element {
        case .news: newsButton
        case .ipnSchedule: ipnScheduleButton
        case .scheduleAvailability: scheduleAvailabilityButton
        case .scheduleReceipt: scheduleReceiptButton
        case .credential: credentialButton
        case .debug: debugWebViewButton
        case .feedback: feedbackButtons
        case .rateApp: rateAppButton
        case .settings: settingsButton
        case .logout: logoutButton
        }
    }

    private var newsButton: some View {
        Button {
            router.navigateTo(.news)
        } label: {
            Label(Localization.news, systemImage: "newspaper.fill")
                .tint(.saes)
        }
    }

    private var ipnScheduleButton: some View {
        Button {
            router.navigateTo(.ipnSchedule)
        } label: {
            Label(Localization.ipnSchedule, systemImage: "calendar.and.person")
                .tint(.saes)
        }
    }

    private var scheduleAvailabilityButton: some View {
        Button {
            router.navigateTo(.scheduleAvailability)
        } label: {
            Label(Localization.scheduleAvailability, systemImage: "chart.bar.horizontal.page.fill")
                .tint(.saes)
        }
    }

    private var scheduleReceiptButton: some View {
        Button {
            scheduleReceiptManager.showCachedPDF()
        } label: {
            Label(Localization.scheduleReceipt, systemImage: ScheduleReceiptManager.icon)
                .tint(.saes)
        }
    }

    private var credentialButton: some View {
        Button {
            router.navigateTo(.credential)
        } label: {
            Label(Localization.myCredential, systemImage: "person.text.rectangle")
                .tint(.saes)
        }
    }

    private var settingsButton: some View {
        Button {
            router.navigateTo(.settings)
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
