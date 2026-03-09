import SwiftUI

struct ScreenshotModeModifier: ViewModifier {
    @AppStorage(AppConstants.UserDefaultsKeys.screenshotMode) private var screenshotMode = false

    func body(content: Content) -> some View {
        content
            .redacted(reason: screenshotMode ? .privacy : [])
    }
}
