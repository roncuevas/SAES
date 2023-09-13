import Foundation
import WebKit

class LoginViewModel: ObservableObject, MessageHandlerDelegate {
    @Published var imageData: Data?
    @Published var isLogged: Bool = false
    var handler: MessageHandler
    var webView: WKWebView
    
    init() {
        handler = MessageHandler()
        
        let userContentController = WKUserContentController()
        userContentController.add(handler, name: "myNativeApp")
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.userContentController = userContentController
        
        self.webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        handler.delegate = self
    }
    
    func dictionaryReceiver(dictionary: [String: Any]) {
        if let imageEncoded = dictionary["imageData"] as? String {
            guard let imageDecoded = imageEncoded.convertDataURIToData() else { return }
            self.imageData = imageDecoded
        }
        if let isLogged = dictionary["isLogged"] as? String {
            self.isLogged = isLogged == "1"
        }
    }
    
    func saveLoginData(boleta: String, password: String) {
    }
}
