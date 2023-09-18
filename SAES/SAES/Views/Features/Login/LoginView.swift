import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var webViewManager: WebViewManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    @AppStorage("isSetted") private var isSetted: Bool = false
    @AppStorage("saesURL") private var saesURL: String = ""
    @AppStorage("boleta") private var boleta: String = ""
    @AppStorage("password") private var password: String = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    
    @StateObject var viewModel: LoginViewModel = .init()
    
    @State var captcha = ""
    @State var debug: Bool = false
    
    var cookies: CookieStorage? {
        let data = UserDefaults.standard.data(forKey: "cookies")
        guard let data = data else { return nil }
        let cookies = try? JSONDecoder().decode(CookieStorage.self, from: data)
        return cookies
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                WebView(webView: $webViewManager.webView)
                    .frame(height: debug ? 500 : 0)
                    .opacity(debug ? 1 : 0)
                    .onAppear {
                        webViewManager.loadURL(url: saesURL, cookies: cookies)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            webViewManager.executeJS(JavaScriptConstants.common)
                            webViewManager.executeJS(JavaScriptConstants.reloadCaptcha)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                webViewManager.executeJS(JavaScriptConstants.getCaptchaImage)
                                captcha = ""
                            }
                        }
                    }
                HStack {
                    Text("Boleta:")
                    TextField("Boleta", text: $boleta)
                }
                HStack {
                    Text("Password:")
                    TextField("Password", text: $password)
                }
                HStack {
                    Button {
                        webViewManager.executeJS(JavaScriptConstants.common)
                        webViewManager.executeJS(JavaScriptConstants.reloadCaptcha)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            webViewManager.executeJS(JavaScriptConstants.getCaptchaImage)
                            captcha = ""
                        }
                    } label: {
                        if let imageData = viewModel.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                        }
                        Text("Reload")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.purple)
                            )
                            .cornerRadius(25)
                    }
                }
                HStack {
                    Text("Captcha:")
                    TextField("Captcha", text: $captcha)
                }
                Group {
                    Button {
                        webViewManager.executeJS(JavaScriptConstants.loginForm(boleta: boleta, password: password, captcha: captcha))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            webViewManager.executeJS(JavaScriptConstants.common)
                            webViewManager.executeJS(JavaScriptConstants.isLogged)
                        }
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
                    Button {
                        isSetted = false
                    } label: {
                        Text("Change school")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.blue)
                            )
                            .cornerRadius(25)
                    }
                }
                #if DEBUG
                Button {
                    debug.toggle()
                } label: {
                    Text("Toggle debug")
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
                #endif
            }
        }
        .padding(.horizontal, 16)
        .onChange(of: viewModel.isLogged) { newValue in
            if newValue {
                isLogged = true
                navigationManager.push(.personalData)
            }
        }
        .onAppear {
            webViewManager.handler.delegate = viewModel
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
