import AppRouter

enum AppSheet: SheetType {
    case debugWebView
    var id: Int { hashValue }
}
