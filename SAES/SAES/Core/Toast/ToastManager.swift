import Foundation
import Toast

@MainActor
final class ToastManager: ObservableObject {
    @Published var toastToPresent: Toast?
    @Published var autoDismissable: Bool = true

    static let shared = ToastManager()
    private init() {}
}
