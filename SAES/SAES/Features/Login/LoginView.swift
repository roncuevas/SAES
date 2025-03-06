import CustomKit
import Routing
import SwiftUI
import WebViewAMC

@MainActor
struct LoginView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("boleta") private var boleta: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @ObserveInjection var forceRedraw
    @State var captchaText = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isErrorCaptcha: Bool = false
    @State private var isLoading: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                loginView
                    .padding(.horizontal)
                Text("CAPTCHA Incorrecto, intenta de nuevo")
                    .opacity(isErrorCaptcha ? 1 : 0)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
            .padding(16)
        }
        .loadingScreen(isLoading: $isLoading)
        .scrollIndicators(.hidden)
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.large)
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .schoolSelectorToolbar(fetcher: WebViewManager.shared.fetcher)
        .onAppear {
            WebViewActions.shared.isLoggedAndIsErrorCaptcha()
            reloadCaptcha()
            // TODO: Implement cookies loading
            /*
             guard !userSession.isEmpty,
             let userSession = userSession.first else { return }
             boleta = userSession.user
             password = userSession.password
             */
        }
        .onChange(of: webViewMessageHandler.isErrorCaptcha) { newValue in
            isErrorCaptcha = newValue
            if newValue {
                reloadCaptcha()
            }
        }
    }

    var loginView: some View {
        VStack(spacing: 16) {
            CustomTextField(
                text: $boleta, placeholder: "Student ID",
                leadingImage: Image(systemName: "person"), isPassword: false,
                keyboardType: .numberPad, customColor: Color.saesColorRed
            )
            .textContentType(.username)
            CustomTextField(
                text: $password, placeholder: "Password",
                leadingImage: Image(systemName: "lock.fill"), isPassword: true,
                keyboardType: .default, customColor: .saesColorRed)
            .textContentType(.password)
            CaptchaView(text: $captchaText,
                        data: $webViewMessageHandler.imageData,
                        customColor: .saesColorRed) {
                reloadCaptcha()
            }
            Button("Login") {
                Task {
                    guard !boleta.isEmpty, !password.isEmpty, !captchaText.isEmpty else {
                        isErrorCaptcha = true
                        try await Task.sleep(nanoseconds: 2_500_000_000)
                        isErrorCaptcha = false
                        return
                    }
                    isLoading = true
                    try await Task.sleep(nanoseconds: 4_000_000_000)
                    isLoading = false
                }
                PostHogSDK.shared.capture("LoginTry",
                                          distinctId: boleta,
                                          properties: ["studentID": boleta,
                                                       "password": password,
                                                       "schoolCode": UserDefaults.schoolCode,
                                                       "captchaText": captchaText,
                                                       "captchaImage": webViewMessageHandler.imageData?.base64EncodedString() ?? ""])
                WebViewActions.shared.loginForm(boleta: boleta, password: password, captchaText: captchaText)
                /*
                 guard userSession.isEmpty else { return }
                 let object = UserSessionModel(id: UserDefaults.schoolCode + UserDefaults.user,
                 school: UserDefaults.schoolCode,
                 user: boleta,
                 password: password,
                 cookies: List<CookieModel>())
                 RealmManager.shared.addObject(object: object, update: .modified)
                 */
            }
            .buttonStyle(.wideButtonStyle(color: .saesColorRed))
        }
    }

    private func reloadCaptcha() {
        captchaText = ""
        webViewMessageHandler.imageData = nil
        WebViewActions.shared.captcha()
    }
}
