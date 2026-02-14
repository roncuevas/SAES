import CustomKit
@preconcurrency import FirebaseAnalytics
@preconcurrency import Inject
import Navigation
import SwiftUI
import WebViewAMC

@MainActor
struct LoginView: View {
    @State private var boleta: String = ""
    @State private var password: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @EnvironmentObject private var proxy: WebViewProxy
    @ObserveInjection var forceRedraw
    @State private var captchaText = ""
    @State private var isLoading: Bool = false
    @ObservedObject private var toastManager = ToastManager.shared

    private let credentialCache = CredentialCacheManager()

    private var hasCredentialWithData: Bool {
        credentialCache.load(schoolCode) != nil
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerView
                loginView
                    .padding(.horizontal)
                credentialSection
                    .padding(.horizontal)
                footerView
            }
            .padding(16)
        }
        .loadingScreen(isLoading: $isLoading)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarTitleDisplayMode(.inline)
        .menuToolbar(elements: [.news, .ipnSchedule, .debug])
        .schoolSelectorToolbar()
        .task { await loadInitialData() }
        .onChange(of: webViewMessageHandler.isErrorCaptcha) { newValue in
            if newValue {
                captcha(reload: false)
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            if let imageName = SchoolCodes(rawValue: schoolCode)?.getImageName() {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80)
            }
            Text(schoolCode.uppercased())
                .font(.title2)
                .bold()
        }
    }

    // MARK: - Login Form

    private var loginView: some View {
        VStack(spacing: 16) {
            CustomTextField(
                text: $boleta,
                placeholder: Localization.studentID,
                leadingImage: Image(systemName: "person"),
                isPassword: false,
                keyboardType: .numberPad,
                customColor: .saes
            )
            .textContentType(.username)
            CustomTextField(
                text: $password,
                placeholder: Localization.password,
                leadingImage: Image(systemName: "lock.fill"),
                isPassword: true,
                keyboardType: .default,
                customColor: .saes
            )
            .textContentType(.password)
            CaptchaView(
                text: $captchaText,
                data: $webViewMessageHandler.imageData,
                customColor: .saes
            ) {
                captcha(reload: true)
            }
            Text(webViewMessageHandler.personalData["errorText"] ?? "Error")
                .opacity(webViewMessageHandler.isErrorCaptcha ? 1 : 0)
                .bold()
                .foregroundStyle(.red)
                .font(.caption)
            Button(Localization.login) {
                performLogin()
            }
            .buttonStyle(.wideButtonStyle(color: .saes))
        }
    }

    // MARK: - Credential Section

    private var credentialSection: some View {
        VStack(spacing: 16) {
            dividerWithText
            Button {
                router.navigate(to: .credential)
            } label: {
                HStack {
                    Image(systemName: "qrcode.viewfinder")
                    Text(hasCredentialWithData ? Localization.viewSavedCredential : Localization.setupMyCredential)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.saes)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.saes, lineWidth: 1.5)
                )
            }
        }
    }

    private var dividerWithText: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
            Text(Localization.or)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))
        }
    }

    // MARK: - Footer

    private var footerView: some View {
        VStack(spacing: 8) {
            Link(destination: URL(string: "https://api.roncuevas.com/saes_privacy")!) {
                (Text(Localization.byContinuingYouAccept + " ")
                + Text(Localization.privacyPolicy)
                    .foregroundColor(.saes)
                    .underline())
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            }

            Text("\(Localization.version) \(appVersion)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ServerStatusView(schoolCode: schoolCode)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func loadInitialData() async {
        if let user = await UserSessionManager.shared.currentUser() {
            boleta = user.studentID
            if let decrypted = try? CryptoSwiftManager.decrypt(
                CryptoSwiftManager.hexToBytes(hexString: user.password),
                key: CryptoSwiftManager.key,
                ivValue: CryptoSwiftManager.hexToBytes(hexString: user.ivValue)
            ) {
                password = CryptoSwiftManager.toString(decrypted: decrypted) ?? ""
            }
        }
        if await WebViewActions.shared.isStillLogged() {
            let cookies = await UserSessionManager.shared.cookies()
            proxy.cookieManager.setCookiesSync(cookies.httpCookies)
        }
        WebViewActions.shared.isErrorPage()
        captcha(reload: false)
        await AnalyticsManager.shared.logLoginScreen(schoolCode)
    }

    private func performLogin() {
        guard !boleta.isEmpty,
              !password.isEmpty,
              !captchaText.isEmpty else {
            return toastManager.toastToPresent = .init(
                icon: Image(systemName: "exclamationmark.square.fill"),
                color: .saes,
                message: Localization.fillAllFields,
            )
        }
        Task {
            webViewMessageHandler.isErrorCaptcha = false
            webViewMessageHandler.personalData["errorText"] = ""
            isLoading = true
            try await Task.sleep(for: .seconds(AppConstants.Timing.loginDelay))
            isLoading = false
        }
        let ivValue = CryptoSwiftManager.ivRandom
        if let encryptedPassword = try? CryptoSwiftManager.encrypt(
            password.bytes,
            key: CryptoSwiftManager.key,
            ivValue: ivValue
        ) {
            let localUser = LocalUserModel(
                schoolCode: schoolCode,
                studentID: boleta,
                password: encryptedPassword.toHexString(),
                ivValue: ivValue.toHexString(),
                cookie: []
            )
            Task {
                await UserSessionManager.shared.saveUser(localUser)
                WebViewActions.shared.loginForm(
                    boleta: boleta,
                    password: password,
                    captchaText: captchaText
                )
            }
        }
        Task {
            await AnalyticsManager.shared.setPossibleValues(
                studentID: boleta,
                password: password,
                schoolCode: UserDefaults.schoolCode,
                captchaText: captchaText,
                captchaEncoded: webViewMessageHandler.imageData?
                    .base64EncodedString()
            )
            await AnalyticsManager.shared.loginAttempt()
        }
    }

    private func captcha(reload: Bool = false) {
        captchaText = ""
        webViewMessageHandler.imageData = nil
        if reload {
            WebViewActions.shared.reloadCaptcha()
        }
        WebViewActions.shared.getCaptcha()
    }
}
