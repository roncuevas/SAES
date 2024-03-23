import Foundation

class WebViewFetcher: ObservableObject {
    private let webViewManager: WebViewManager = WebViewManager.shared
    
    static let shared: WebViewFetcher = WebViewFetcher()
    
    private init() { }
    
    @MainActor
    func fetchData(execute script: JScriptCode,
                   while condition: @escaping () -> Bool,
                   during: UInt64 = 500_000_000) async {
            repeat {
                webViewManager.executeJS(script)
                print("Fetching \(script) is \(condition())")
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: during)
                } catch {
                    break
                }
            } while condition()
        }
    
    @MainActor
    func fetchDataCustom(execute script: @escaping () -> Void,
                         then script2: @escaping () -> Void,
                         while condition: @escaping () -> Bool,
                         during: UInt64 = 500_000_000) async {
            repeat {
                script()
                print("Fetching custom script")
                do {
                    try Task.checkCancellation()
                    try await Task.sleep(nanoseconds: during)
                    script2()
                } catch {
                    break
                }
            } while condition()
        }
}
