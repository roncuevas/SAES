import SwiftUI

struct ScreenTraceModifier: ViewModifier {
    let screenName: String

    func body(content: Content) -> some View {
        content
            .onAppear {
                Task {
                    await PerformanceManager.shared.startTrace(
                        name: "screen_\(screenName)",
                        attributes: ["school_code": UserDefaults.schoolCode]
                    )
                }
            }
            .onDisappear {
                Task {
                    await PerformanceManager.shared.stopTrace(name: "screen_\(screenName)")
                }
            }
    }
}

extension View {
    func screenTrace(_ name: String) -> some View {
        modifier(ScreenTraceModifier(screenName: name))
    }
}
