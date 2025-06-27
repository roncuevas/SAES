import Foundation
import Toast

final class ToastManager: ObservableObject {
    @Published var isShowingToast: Bool = false
    @Published var toastToPresent: Toast?
    @Published var autoDismissable: Bool = true

    static let shared = ToastManager()
    private init() {}
}
