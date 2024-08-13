import SwiftUI
import Routing
import RealmSwift

struct LoginView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var webViewManager: WebViewManager
    @EnvironmentObject private var webViewMessageHandler: WebViewMessageHandler
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State var captcha = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isErrorCaptcha: Bool = false
    private let actor: WebViewDataFetcher = WebViewDataFetcher()
    @ObservedResults(UserSessionModel.self,
                     where: { $0.school == UserDefaults.schoolCode }) private var userSession
    
    let isLoggedRefreshRate: UInt64 = 500_000_000
    
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
        .navigationTitle("Login")
        .webViewToolbar(webView: webViewManager.webView)
        .schoolSelectorToolbar()
        .padding(.horizontal, 16)
        .onAppear {
            webViewManager.loadURL(url: .base, cookies: UserSessionModel.getFirst()?.cookies)
            guard !userSession.isEmpty,
                    let userSession = userSession.first else { return }
            boleta = userSession.user
            password = userSession.password
        }
        .task {
            await actor.fetchCaptcha()
        }
        .onChange(of: isLogged) { newValue in
            if newValue && (router.stack.last != .logged) {
                router.navigate(to: .logged)
            }
        }
        .onChange(of: webViewMessageHandler.isErrorCaptcha) { newValue in
            isErrorCaptcha = newValue
            if newValue {
                webViewManager.loadURL(url: .base)
                captcha = ""
                Task { await actor.fetchCaptcha() }
            }
        }
    }
    
    var loginView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Boleta:")
                TextField("Boleta", text: $boleta)
            }
            HStack {
                Text("Password:")
                if isPasswordVisible {
                    TextField("********", text: $password)
                } else {
                    SecureField("********", text: $password)
                }
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .tint(colorScheme == .dark ? .white : .black)
                }
                .padding(.trailing, 16)
            }
            captchaView
            HStack {
                Text("Captcha:")
                TextField("Captcha", text: $captcha)
                    .textInputAutocapitalization(.characters)
            }
            Group {
                Button {
                    webViewManager.executeJS(.loginForm(boleta, password, captcha))
                    guard userSession.isEmpty else { return }
                    let object = UserSessionModel(id: UserDefaults.schoolCode + UserDefaults.user,
                                                  school: UserDefaults.schoolCode,
                                                  user: boleta,
                                                  password: password,
                                                  cookies: List<CookieModel>())
                    RealmManager.shared.addObject(object: object, update: .modified)
                } label: {
                    Text("Login")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.red)
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
            }
            Button {
                Task {
                    await actor.fetchCaptcha()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 32))
                    .fontWeight(.light)
                    .tint(colorScheme == .dark ? .white : .black)
            }
        }
    }
}
