import CustomKit
@preconcurrency import FirebaseAnalytics
@preconcurrency import Inject
import SwiftUI
import WebViewAMC

@MainActor
struct LoginView: View {
    @State private var boleta: String = ""
    @State private var password: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var proxy: WebViewProxy
    @ObserveInjection var forceRedraw
    @State private var captchaText = ""
    @State private var isLoading: Bool = false
    @State private var serverOnline: Bool?
    @State private var showServerUnavailableAlert = false
    @ObservedObject private var toastManager = ToastManager.shared

    private let credentialCache = CredentialCacheManager()
    private let logger = Logger()

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
        .saesLoadingScreen(isLoading: $isLoading)
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarTitleDisplayMode(.inline)
        .menuToolbar(items: MenuConfiguration.login.items)
        .schoolSelectorToolbar()
        .task { await loadInitialData() }
        .task(id: schoolCode) {
            serverOnline = await ServerStatusService.fetchStatus(for: schoolCode)
        }
        .onChange(of: serverOnline) { newValue in
            if newValue == false {
                showServerUnavailableAlert = true
            }
        }
        .alert(Localization.serverUnavailable, isPresented: $showServerUnavailableAlert) {
            Button(Localization.okey, role: .cancel) {}
        } message: {
            Text(Localization.serverUnavailableMessage(schoolCode.uppercased()))
        }
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
            SAESCaptchaView(
                text: $captchaText,
                data: $webViewMessageHandler.imageData,
                customColor: .saes
            ) {
                captcha(reload: true)
            }
            .onSubmit {
                performLogin()
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
                router.navigateTo(.credential)
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
            (Text(Localization.byContinuingYouAccept + " ")
            + Text(Localization.privacyPolicy))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("\(Localization.version) \(appVersion)")
                .font(.caption2)
                .foregroundStyle(.secondary)

            ServerStatusView(isOnline: serverOnline)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func loadInitialData() async {
        if let user = await UserSessionManager.shared.currentUser() {
            logger.log(level: .info, message: "Usuario encontrado: \(user.studentID)", source: "LoginView")
            boleta = user.studentID
            do {
                let decrypted = try CryptoSwiftManager.decrypt(
                    CryptoSwiftManager.hexToBytes(hexString: user.password),
                    key: CryptoSwiftManager.key,
                    ivValue: CryptoSwiftManager.hexToBytes(hexString: user.ivValue)
                )
                password = CryptoSwiftManager.toString(decrypted: decrypted) ?? ""
            } catch {
                logger.log(level: .warning, message: "Fallo al desencriptar contraseña guardada: \(error)", source: "LoginView")
            }
        } else {
            logger.log(level: .warning, message: "No se encontró usuario guardado", source: "LoginView")
        }
        WebViewActions.shared.isErrorPage()
        captcha(reload: false)
        logger.log(level: .info, message: "Captcha y monitoreo de errores iniciados", source: "LoginView")
        await AnalyticsManager.shared.logLoginScreen(schoolCode)
    }

    private func performLogin() {
        logger.log(level: .info, message: "Login iniciado con boleta: \(boleta)", source: "LoginView")
        guard !boleta.isEmpty,
              !password.isEmpty,
              !captchaText.isEmpty else {
            logger.log(level: .warning, message: "Campos vacíos, login cancelado", source: "LoginView")
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
        do {
            let encryptedPassword = try CryptoSwiftManager.encrypt(
                password.bytes,
                key: CryptoSwiftManager.key,
                ivValue: ivValue
            )
            let localUser = LocalUserModel(
                schoolCode: schoolCode,
                studentID: boleta,
                password: encryptedPassword.toHexString(),
                ivValue: ivValue.toHexString(),
                cookie: []
            )
            Task {
                await UserSessionManager.shared.saveUser(localUser)
            }
        } catch {
            logger.log(level: .warning, message: "Encriptación falló: \(error), credenciales no se guardarán", source: "LoginView")
        }
        WebViewActions.shared.loginForm(
            boleta: boleta,
            password: password,
            captchaText: captchaText
        )
        logger.log(level: .info, message: "loginForm enviado al WebView", source: "LoginView")
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
        logger.log(level: .info, message: "Captcha solicitado (reload: \(reload))", source: "LoginView")
        captchaText = ""
        webViewMessageHandler.imageData = nil
        if reload {
            WebViewActions.shared.reloadCaptcha()
        }
        WebViewActions.shared.getCaptcha()
    }
}
