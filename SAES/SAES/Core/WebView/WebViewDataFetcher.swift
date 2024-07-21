import Foundation

actor WebViewDataFetcher {
    let webViewManager: WebViewManager = WebViewManager.shared
    let webViewMessageHandler: WebViewMessageHandler = WebViewMessageHandler.shared
    
    @MainActor
    private func fetchData(execute script: JScriptCode,
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
    private func fetchDataCustom(execute script: @escaping () -> Void,
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
    
    func fetchLoggedAndErrors() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.getLogged() }
            group.addTask { await self.getErrorPage() }
        }
    }
    
    func fetchPersonalDataAndProfileImage() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.getPersonalData() }
            group.addTask { await self.getProfileImage() }
        }
    }
    
    func fetchCaptcha() async {
        await fetchDataCustom {
            self.webViewManager.executeJS(.reloadCaptcha)
        } then: {
            self.webViewManager.executeJS(.getCaptchaImage)
        } while: {
            self.webViewMessageHandler.imageData.isEmptyOrNil
        }
    }
    
    func fetchSchedule() async {
        await fetchData(execute: .schedule) {
            self.webViewMessageHandler.schedule.isEmpty
        }
    }
    
    private func getLogged() async {
        await fetchData(execute: .isLogged) {
            true
        }
    }
    
    private func getErrorPage() async {
        await fetchData(execute: .isErrorPage) {
            true
        }
    }
    
    private func getPersonalData() async {
        await fetchData(execute: .personalData) {
            self.webViewMessageHandler.name.isEmpty
        }
    }
    
    private func getProfileImage() async {
        await fetchData(execute: .getProfileImage) {
            self.webViewMessageHandler.profileImageData.isEmptyOrNil
        }
    }
}

extension WebViewDataFetcher {
    func fetchGrades() async {
        await fetchData(execute: .grades) {
            self.webViewMessageHandler.grades.isEmpty
        }
    }
}

extension WebViewDataFetcher {
    func fetchKardex() async {
        await fetchData(execute: .kardex) {
            !self.webViewMessageHandler.kardex.0
        }
    }
}
