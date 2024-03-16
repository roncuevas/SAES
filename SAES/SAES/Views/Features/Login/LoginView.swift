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
    @State var debug: Bool = false
    @State private var isPasswordVisible: Bool = false
    @StateObject var viewModel: LoginViewModel = LoginViewModel()
    
    var cookies: CookieStorage? {
        let data = UserDefaults.standard.data(forKey: "cookies")
        guard let data = data else { return nil }
        let cookies = try? JSONDecoder().decode(CookieStorage.self, from: data)
        return cookies
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                webView
                loginView
            }
        }
        .navigationTitle("Login")
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    debug.toggle()
                } label: {
                    Image(systemName: "ladybug.fill")
                        .tint(.black)
                }
            }
            #endif
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isSetted = false
                } label: {
                    Image(systemName: "graduationcap.fill")
                        .tint(.black)
                }
            }
        }
        .padding(.horizontal, 16)
        .onChange(of: isLogged) { newValue in
            print("isLogged changed to: \(isLogged)")
            if newValue {
                router.navigate(to: .personalData)
            }
        }
        .onAppear {
            webViewManager.handler.delegate = viewModel
            if isLogged {
                router.navigate(to: .personalData)
            }
        }
        .task {
            await fetchLogged()
        }
    }
    
    var webView: some View {
        WebView(webView: $webViewManager.webView)
            .frame(height: debug ? 500 : 0)
            .onAppear {
                webViewManager.loadURL(url: saesURL)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    webViewManager.executeJS(.reloadCaptcha)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        webViewManager.executeJS(.getCaptchaImage)
                        captcha = ""
                    }
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
                webViewManager.executeJS(.reloadCaptcha)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    webViewManager.executeJS(.getCaptchaImage)
                    captcha = ""
                }
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath.circle")
                    .font(.system(size: 32))
                    .fontWeight(.light)
                    .tint(.black)
            }
        }
    }
    
    func fetchLogged() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        print("Logged: \(isLogged)")
        var counter: Int = 0
        while isLogged == false {
            webViewManager.executeJS(.isLogged)
            print("\(counter) - isLogged: \(isLogged)")
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            counter += 1
        }
    }
}
