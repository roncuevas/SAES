@preconcurrency import FirebaseRemoteConfig
import RevenueCatUI
import SwiftUI
import WebViewAMC

struct MenuViewModifier: ViewModifier {
    @State private var debug = false
    @State private var showPaywall = false
    @State private var showCelebration = false
    @EnvironmentObject private var proxy: WebViewProxy
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @ObservedObject private var scheduleReceiptManager = ScheduleReceiptManager.shared
    private let credentialCache: CredentialCacheClient = CredentialCacheManager()
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnNewsScreen,
        fallback: true
    ) private var newsEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnScheduleScreen,
        fallback: true
    ) private var ipnScheduleEnabled
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .onPurchaseCompleted { _ in
                        showPaywall = false
                        showCelebration = true
                    }
            }
            .overlay {
                if showCelebration {
                    EmojiCelebrationView {
                        showCelebration = false
                    }
                }
            }
            .sheet(isPresented: $debug) {
                WebView(proxy: proxy)
                    .frame(height: 500)
            }
            .quickLookPreview($scheduleReceiptManager.pdfURL)
            .onAppear {
                scheduleReceiptManager.refreshCacheState()
            }
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
        case .scheduleAvailability: return false
        case .scheduleReceipt: return scheduleReceiptManager.hasCachedPDF
        case .credential: return credentialCache.hasCredential(for: schoolCode)
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

    // MARK: - Element rendering

    @ViewBuilder
    private func renderElement(_ element: MenuElement) -> some View {
        switch element {
        case .news:
            MenuNavigationButton(title: Localization.news, icon: "newspaper.fill", destination: .news)
        case .announcements:
            MenuNavigationButton(title: Localization.announcements, icon: "megaphone.fill", destination: .announcements)
        case .scholarships:
            MenuNavigationButton(title: Localization.becas, icon: "graduationcap.fill", destination: .scholarships)
        case .ipnSchedule:
            MenuNavigationButton(title: Localization.ipnSchedule, icon: "calendar.and.person", destination: .ipnSchedule)
        case .scheduleAvailability:
            MenuNavigationButton(title: Localization.scheduleAvailability, icon: "chart.bar.horizontal.page.fill", destination: .scheduleAvailability)
        case .credential:
            MenuNavigationButton(title: Localization.myCredential, icon: "person.text.rectangle", destination: .credential)
        case .settings:
            MenuNavigationButton(title: Localization.settings, icon: "gearshape", destination: .settings)
        case .scheduleReceipt:
            MenuScheduleReceiptButton()
        case .privacyPolicy:
            MenuLinkButton(title: Localization.privacyPolicy, icon: "hand.raised.fill", url: URLConstants.privacyPolicy)
                .tint(.saes)
        case .buyMeACoffee:
            MenuBuyMeACoffeeButton(showPaywall: $showPaywall)
        case .feedback:
            MenuFeedbackSection()
        case .rateApp:
            MenuRateAppButton()
        case .debug:
            MenuDebugButton(isPresented: $debug)
        case .logout:
            MenuLogoutButton()
        }
    }
}
