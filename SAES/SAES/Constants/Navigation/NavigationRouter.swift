import SwiftUI

@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ destination: AppDestination) {
        path.append(destination)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popAll() {
        path = NavigationPath()
    }
}
