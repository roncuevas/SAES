import SwiftUI
import Navigation

@MainActor
final class Router<T: Destination>: ObservableObject {
    @Published var stack: [T] = []

    func navigate(to destination: T) {
        stack.navigate(to: destination)
    }

    func navigateBack() {
        stack.navigateBack()
    }

    func navigateToRoot() {
        stack.navigateToRoot()
    }
}
