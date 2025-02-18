import Routing
import SwiftUI
import WebViewAMC

struct LoginView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State var captcha = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isErrorCaptcha: Bool = false
    
    var body: some View {
        let _ = Self._printChanges()
        ScrollView {
            VStack(spacing: 16) {
                loginView
                Text("CAPTCHA Incorrecto, intenta de nuevo")
                    .opacity(isErrorCaptcha ? 1 : 0)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Login")
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .schoolSelectorToolbar()
        .padding(.horizontal, 16)
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
        .onChange(of: isLogged) { (_, newValue) in
            if newValue && (router.stack.last != .logged) {
                router.navigate(to: .logged)
            }
        }
        .onChange(of: webViewMessageHandler.isErrorCaptcha) { (_, newValue) in
            isErrorCaptcha = newValue
            if newValue {
                reloadCaptcha()
            }
        }
    }
    
    var loginView: some View {
        VStack {
            HStack {
                CustomTextField(
                    text: $boleta, placeholder: "Student ID",
                    imageTF: Image(systemName: "person"), isPassword: true,
                    keyboardType: .numberPad, color: .saesColorRed
                )
                .padding()
            }
            HStack {
                CustomTextField(
                    text: $password, placeholder: "Password",
                    imageTF: .init(systemName: "lock.fill"), isPassword: true,
                    keyboardType: .default, color: .saesColorRed
                )
                .padding()
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color.gray.opacity(0.3))
                VStack {
                    captchaView
                    HStack {
                        TextField("Captcha", text: $captcha)
                            .textInputAutocapitalization(.characters)
                    }
                }
                .padding()
            }
            .padding()
            Group {
                Button {
                    WebViewManager.shared.webView.injectJavaScript(
                        handlerName: WebViewManager.handlerName,
                        javaScript: JScriptCode.loginForm(
                            boleta, password, captcha
                        ).value)
                    /*
                     guard userSession.isEmpty else { return }
                     let object = UserSessionModel(id: UserDefaults.schoolCode + UserDefaults.user,
                     school: UserDefaults.schoolCode,
                     user: boleta,
                     password: password,
                     cookies: List<CookieModel>())
                     RealmManager.shared.addObject(object: object, update: .modified)
                     */
                } label: {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.saesColorRed)
                        )
                        .cornerRadius(25)
                }
            }
        }
    }
    
    var captchaView: some View {
        HStack {
            if let imageData = webViewMessageHandler.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(height: 50)
            }
            Button {
                reloadCaptcha()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 24))
                    .fontWeight(.thin)
                    .tint(colorScheme == .dark ? .white : .gray)
            }
        }
    }
    
    private func reloadCaptcha() {
        captcha = ""
        webViewMessageHandler.imageData = nil
        Task {
            await WebViewManager.shared.fetcher.addTask(
                from: URLConstants.base.value,
                delayToRun: 500_000_000,
                fetch: [
                    DataFetchRequest(
                        javaScript: JScriptCode.reloadCaptcha.value,
                        description: "reloadCaptcha", iterations: 1),
                    DataFetchRequest(
                        javaScript: JScriptCode.getCaptchaImage.value,
                        description: "getCaptchaImage"
                    ) {
                        webViewMessageHandler.imageData.isEmptyOrNil
                    },
                ])
        }
    }
}
