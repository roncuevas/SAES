import CustomKit
import FirebaseAnalytics
import Inject
import Navigation
import SwiftUI
import WebViewAMC

@MainActor
struct LoginView: View {
    @State private var boleta: String = ""
    @State private var password: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @ObserveInjection var forceRedraw
    @State var captchaText = ""
    @State private var isLoading: Bool = false
    @ObservedObject private var toastManager = ToastManager.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    if let imageName = SchoolCodes(rawValue: schoolCode)?.getImageName() {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 70)
                        Text(schoolCode.uppercased())
                            .font(.headline)
                            .padding(.leading, 4)
                    }
                }
                loginView
                    .padding(.horizontal)
                Text(webViewMessageHandler.personalData["errorText"] ?? "Error")
                    .opacity(webViewMessageHandler.isErrorCaptcha ? 1 : 0)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
            .padding(16)
        }
        .loadingScreen(isLoading: $isLoading)
        .scrollIndicators(.hidden)
        .navigationTitle(Localization.login)
        .navigationBarTitleDisplayMode(.large)
        .menuToolbar(elements: [.news, .ipnSchedule, .debug])
        .schoolSelectorToolbar(fetcher: WebViewManager.shared.fetcher)
        .task {
            if let user = await UserSessionManager.shared.currentUser() {
                boleta = user.studentID
                guard let decrypted = try? CryptoSwiftManager.decrypt(
                    CryptoSwiftManager.hexToBytes(hexString: user.password),
                    key: CryptoSwiftManager.key,
                    ivValue: CryptoSwiftManager.hexToBytes(hexString: user.ivValue)
                ) else { return }
                password = CryptoSwiftManager.toString(decrypted: decrypted) ?? ""
            }
            if await WebViewActions.shared.isStillLogged() {
                let cookies = await UserSessionManager.shared.cookies()
                WebViewManager.shared.webView.setCookies(cookies.httpCookies)
            }
            WebViewActions.shared.isErrorPage()
            captcha(reload: false)
            AnalyticsManager.shared.logLoginScreen(schoolCode)
        }
        .onChange(of: webViewMessageHandler.isErrorCaptcha) { newValue in
            if newValue {
                captcha(reload: false)
            }
        }
    }

    var loginView: some View {
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
            Button(Localization.login) {
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
                    }
                }
                AnalyticsManager.shared.setPossibleValues(
                    studentID: boleta,
                    password: password,
                    schoolCode: UserDefaults.schoolCode,
                    captchaText: captchaText,
                    captchaEncoded: webViewMessageHandler.imageData?
                        .base64EncodedString()
                )
                AnalyticsManager.shared.loginAttempt()
                WebViewActions.shared.loginForm(
                    boleta: boleta,
                    password: password,
                    captchaText: captchaText
                )
            }
            .buttonStyle(.wideButtonStyle(color: .saes))
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
