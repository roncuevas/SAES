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
    @State var captcha = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isErrorCaptcha: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                loginView
                Text("CAPTCHA Incorrecto, intenta de nuevo")
                    .opacity(isErrorCaptcha ? 1 : 0)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Login")
        .navigationBarTitleDisplayMode(.large)
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .schoolSelectorToolbar(fetcher: WebViewManager.shared.fetcher)
        .padding(16)
        .onAppear {
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
            CaptchaView(
                data: $webViewMessageHandler.imageData,
                reloadAction: reloadCaptcha)
                .padding()
            CustomTextField(
                text: $captcha,
                placeholder: "CAPTCHA",
                leadingImage: .init(systemName: "shield.checkerboard"),
                textAlignment: .topLeading,
                isPassword: false,
                keyboardType: .default,
                customColor: .saesColorRed,
                autocorrectionDisabled: true)
            .textFieldStyle(.textFieldUppercased)
            Button("Login") {
                Task {
                    await WebViewManager.shared.fetcher.fetch([
                        DataFetchRequest(id: "loginForm",
                                         javaScript: JScriptCode.loginForm(boleta, password, captcha).value,
                                         iterations: 1)
                    ])
                }
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
        .padding(.horizontal)
    }

    private func reloadCaptcha() {
        captcha = ""
        webViewMessageHandler.imageData = nil
        Task {
            await WebViewManager.shared.fetcher.fetch([
                DataFetchRequest(
                    id: "reloadCaptcha",
                    url: URLConstants.base.value,
                    javaScript: JScriptCode.reloadCaptcha.value,
                    iterations: 1),
                DataFetchRequest(
                    id: "getCaptchaImage",
                    url: URLConstants.base.value,
                    javaScript: JScriptCode.getCaptchaImage.value) {
                    webViewMessageHandler.imageData.isEmptyOrNil
                }
            ])
        }
    }
}
