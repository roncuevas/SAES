import WebKit

protocol MessageHandlerDelegate: AnyObject {
    func dictionaryReceiver(dictionary: Dictionary<String, Any>)
}

class MessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: MessageHandlerDelegate?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let message = message.body as? Dictionary<String, Any> {
            guard let delegate = delegate else { return }
            delegate.dictionaryReceiver(dictionary: message)
        }
    }
}
