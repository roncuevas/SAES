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
        .scrollIndicators(.hidden)
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.large)
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .schoolSelectorToolbar(fetcher: WebViewManager.shared.fetcher)
        .onAppear {
            WebViewManager.shared.fetcher.debugTaskManager()
            WebViewManager.shared.fetcher.fetch([
                DataFetchRequest(id: "isLogged",
                                 javaScript: JScriptCode.isLogged.value,
                                 verbose: false,
                                 condition: { true }),
                DataFetchRequest(id: "isErrorPage",
                                 javaScript: JScriptCode.isErrorPage.value,
                                 verbose: false,
                                 condition: { true })
            ], for: URLConstants.base.value)
            reloadCaptcha()
            // TODO: Implement cookies loading
            /*
             guard !userSession.isEmpty,
             let userSession = userSession.first else { return }
             boleta = userSession.user
             password = userSession.password
             */
        }
        .onChange(of: isLogged) { newValue in
            if newValue && (router.stack.last != .logged) {
                router.navigate(to: .logged)
            }
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
                leadingImage: .init(systemName: "lock.fill"), isPassword: true,
                keyboardType: .default, customColor: .saesColorRed)
            .textContentType(.password)
            CaptchaView(text: $captchaText,
                        data: $webViewMessageHandler.imageData,
                        customColor: .saesColorRed) {
                reloadCaptcha()
            }
            Button("Login") {
                PostHogSDK.shared.capture("LoginTry",
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
        WebViewManager.shared.fetcher.fetch([
            DataFetchRequest(
                id: "reloadCaptcha",
                javaScript: JScriptCode.reloadCaptcha.value,
                iterations: 1),
            DataFetchRequest(
                id: "getCaptchaImage",
                javaScript: JScriptCode.getCaptchaImage.value,
                verbose: false) {
                    webViewMessageHandler.imageData.isEmptyOrNil
                }
        ], for: URLConstants.base.value)
    }
}
