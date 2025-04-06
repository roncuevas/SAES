import CustomKit
import Routing
import SwiftUI
import WebViewAMC
import Inject
import FirebaseAnalytics

@MainActor
struct LoginView: View {
    @State private var boleta: String = ""
    @State private var password: String = ""
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @EnvironmentObject private var webViewMessageHandler: WebViewHandler
    @ObserveInjection var forceRedraw
    @State var captchaText = ""
    @State private var isLoading: Bool = false
    @State private var statements: IPNStatementModel?
    @Environment(\.openURL) private var openURL
    
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
                #if DEBUG
                Text(Localization.news)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.saes)
                    .padding(.top, -16)
                    .padding(.bottom)
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach(statements ?? []) { statement in
                            if let url = URL(string: "https://www.ipn.mx\(statement.imageURL)") {
                                VStack(spacing: 8) {
                                    Text(statement.title)
                                        .font(.headline)
                                        .multilineTextAlignment(.leading)
                                        .foregroundStyle(.saes)
                                    Text(statement.date)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.saes)
                                        .multilineTextAlignment(.leading)
                                }
                                .frame(width: UIScreen.main.bounds.width - 110, height: 250)
                                .padding()
                                .background {
                                    ZStack {
                                        AsyncImage(url: url) { image in
                                            image
                                                .image?.resizable()
                                                .clipShape(RoundedRectangle(cornerRadius: 80))
                                        }
                                        Color.white.opacity(0.7)
                                            .frame(height: 130)
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 80)
                                        .stroke(.saes, lineWidth: 1)
                                }
                                .onTapGesture {
                                    guard let url = URL(string: "https://www.ipn.mx\(statement.link)") else { return }
                                    openURL(url)
                                }
                            } else {
                                EmptyView()
                            }
                        }
                    }
                }
                .padding(.top, -16)
                #endif
            }
            .padding(16)
        }
        .loadingScreen(isLoading: $isLoading)
        .scrollIndicators(.hidden)
        .navigationTitle(Localization.login)
        .navigationBarTitleDisplayMode(.large)
        .webViewToolbar(webView: WebViewManager.shared.webView)
        .schoolSelectorToolbar(fetcher: WebViewManager.shared.fetcher)
        .onAppear {
            var user = LocalStorageManager.loadLocalUser(schoolCode)
            boleta = user?.studentID ?? ""
            password = user?.password ?? ""
            let cookies = LocalStorageManager.loadLocalCookies(schoolCode)
            WebViewManager.shared.webView.setCookies(cookies.httpCookies)
            WebViewActions.shared.isErrorPage()
            captcha(reload: false)
            Analytics.logEvent("screen_login_\(schoolCode)", parameters: nil)
            // TODO: Implement cookies loading
            /*
             guard !userSession.isEmpty,
             let userSession = userSession.first else { return }
             boleta = userSession.user
             password = userSession.password
             */
        }
        .task {
            do {
                self.statements = try await NetworkManager.shared.sendRequest(url: "https://api.roncuevas.com/ipn/statements",
                                                                              type: IPNStatementModel.self)
            } catch {
                print(error)
            }
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
                text: $boleta, placeholder: Localization.studentID,
                leadingImage: Image(systemName: "person"), isPassword: false,
                keyboardType: .numberPad, customColor: .saes
            )
            .textContentType(.username)
            CustomTextField(
                text: $password, placeholder: Localization.password,
                leadingImage: Image(systemName: "lock.fill"), isPassword: true,
                keyboardType: .default, customColor: .saes)
            .textContentType(.password)
            CaptchaView(text: $captchaText,
                        data: $webViewMessageHandler.imageData,
                        customColor: .saes) {
                captcha(reload: true)
            }
            Button(Localization.login) {
                Task {
                    webViewMessageHandler.isErrorCaptcha = false
                    webViewMessageHandler.personalData["errorText"] = ""
                    guard !boleta.isEmpty, !password.isEmpty, !captchaText.isEmpty else {
                        // isError = true
                        try await Task.sleep(nanoseconds: 2_500_000_000)
                        // isError = false
                        return
                    }
                    isLoading = true
                    try await Task.sleep(nanoseconds: 4_000_000_000)
                    isLoading = false
                }
                let localUser = LocalUserModel(schoolCode: schoolCode,
                                               studentID: boleta,
                                               password: password,
                                               cookie: [])
                LocalStorageManager.saveLocalUser(schoolCode, data: localUser)
                AnalyticsManager.shared.setPossibleValues(studentID: boleta,
                                                          password: password,
                                                          schoolCode: UserDefaults.schoolCode,
                                                          captchaText: captchaText,
                                                          captchaEncoded: webViewMessageHandler.imageData?.base64EncodedString())
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
