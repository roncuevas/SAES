import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var viewModel: LoginViewModel
    @AppStorage("boleta") var boleta = ""
    @AppStorage("password") var password = ""
    @AppStorage("isLogged") private var isLogged: Bool = false
    @State var captcha = ""
    @State var debug: Bool = false
    let cookies = UserDefaults.standard.object(forKey: "cookies") as? [HTTPCookie]
    
    var body: some View {
        ScrollView {
            VStack {
                WebView(webView: $viewModel.webView, url: EndpointConstants.enmh, cookies: cookies)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewModel.webView.evaluateJavaScript(JavaScriptConstants.common)
                            viewModel.webView.evaluateJavaScript(JavaScriptConstants.getCaptchaImage)
                        }
                    }
                    .frame(height: debug ? 500 : 0)
                    .opacity(debug ? 1 : 0)
                VStack {
                    Text("Boleta")
                    TextField("Boleta", text: $boleta)
                    Text("Password")
                    TextField("Password", text: $password)
                    if let imageData = viewModel.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                    }
                    Text("Captcha")
                    TextField("Captcha", text: $captcha)
                    Button {
                        viewModel.webView.evaluateJavaScript(JavaScriptConstants.common)
                        viewModel.webView.evaluateJavaScript(JavaScriptConstants.reloadCaptcha)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            viewModel.webView.evaluateJavaScript(JavaScriptConstants.getCaptchaImage)
                            captcha = ""
                        }
                    } label: {
                        Text("Reload Captcha")
                    }
                    Button {
                        viewModel.webView.evaluateJavaScript(JavaScriptConstants.loginForm(boleta: boleta, password: password, captcha: captcha))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            viewModel.webView.evaluateJavaScript(JavaScriptConstants.common)
                            viewModel.webView.evaluateJavaScript(JavaScriptConstants.isLogged)
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
        }
        .padding(.horizontal, 16)
        .onChange(of: viewModel.isLogged) { newValue in
            if newValue {
                isLogged = true
                navigationManager.push(.personalData)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
