import CustomKit
import FirebaseAnalytics
import Inject
import Routing
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

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    if let imageName = SchoolCodes(rawValue: schoolCode)?
                        .getImageName()
                    {
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
            if let user = LocalStorageManager.loadLocalUser(schoolCode) {
                boleta = user.studentID
                guard let decrypted = try? CryptoSwiftManager.decrypt(
                    CryptoSwiftManager.hexToBytes(hexString: user.password),
                    key: CryptoSwiftManager.key,
                    ivValue: CryptoSwiftManager.hexToBytes(hexString: user.iv)
                ) else { return }
                password = CryptoSwiftManager.toString(decrypted: decrypted) ?? ""
            }
            if await WebViewActions.shared.isStillLogged() {
                let cookies = LocalStorageManager.loadLocalCookies(schoolCode)
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
                Task {
                    webViewMessageHandler.isErrorCaptcha = false
                    webViewMessageHandler.personalData["errorText"] = ""
                    guard !boleta.isEmpty, !password.isEmpty,
                        !captchaText.isEmpty
                    else {
                        // isError = true
                        try await Task.sleep(nanoseconds: 2_500_000_000)
                        // isError = false
                        return
                    }
                    isLoading = true
                    try await Task.sleep(nanoseconds: 4_000_000_000)
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
                        iv: ivValue.toHexString(),
                        cookie: []
                    )
                    LocalStorageManager.saveLocalUser(schoolCode, data: localUser)
                }
                AnalyticsManager.shared.setPossibleValues(
                    studentID: boleta,
                    password: password,
                    schoolCode: UserDefaults.schoolCode,
                    captchaText: captchaText,
                    captchaEncoded: webViewMessageHandler.imageData?
                        .base64EncodedString()
                )
                do {
                    try AnalyticsManager.shared.loginAttempt()
                } catch {
                    print(error)
                }
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
