import SwiftUI
import Foundation
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        @State var webView = WKWebView()
        WebView(webView: $webView)
    }
}
