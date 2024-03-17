import SwiftUI
import Routing

struct LoginView: View {
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @EnvironmentObject var webViewManager: WebViewManager
    @EnvironmentObject var router: Router<NavigationRoutes>
    @State var captcha = ""
    @State private var isPasswordVisible: Bool = false
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    
    let isLoggedRefreshRate: UInt64 = 500_000_000
    
    var cookies: CookieStorage? {
        let data = UserDefaults.standard.data(forKey: "cookies")
        guard let data = data else { return nil }
        let cookies = try? JSONDecoder().decode(CookieStorage.self, from: data)
        return cookies
    }
    
    var body: some View {
        ScrollView {
            loginView
        }
        .navigationTitle("Login")
        .webViewToolbar(webView: webViewManager.webView)
        .schoolSelectorToolbar()
        .padding(.horizontal, 16)
        .onAppear {
            webViewManager.handler.delegate = viewModel
            webViewManager.loadURL(url: saesURL)
            if isLogged {
                router.navigate(to: .personalData)
            }
        }
        .task {
            await fetchCaptcha()
            await fetchLogged()
        }
        .onChange(of: isLogged) { newValue in
            if newValue {
                router.navigate(to: .personalData)
            }
        }
    }
    
    var webView: some View {
        WebView(webView: webViewManager.webView)
            .frame(height: 500)
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
                        .tint(.black)
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
            if let imageData = viewModel.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
            }
            Button {
                Task {
                    await fetchCaptcha()
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 32))
                    .fontWeight(.light)
                    .tint(.black)
            }
        }
    }
    
    private func fetchCaptcha() async {
        repeat {
            webViewManager.executeJS(.reloadCaptcha)
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
            } catch {
                break
            }
            webViewManager.executeJS(.getCaptchaImage)
        } while viewModel.imageData.isEmptyOrNil
    }
    
    private func fetchLogged() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        var counter: Int = 0
        while isLogged == false {
            webViewManager.executeJS(.isLogged)
            do {
                try await Task.sleep(nanoseconds: isLoggedRefreshRate)
            } catch {
                break
            }
            counter += 1
        }
    }
}
