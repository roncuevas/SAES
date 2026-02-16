import Combine
import Foundation

@MainActor
protocol SAESLoadingStateManager: ObservableObject {
    var loadingState: SAESLoadingState { get set }
    func setLoadingState(_ state: SAESLoadingState)
    func performLoading<T>(_ operation: @escaping @Sendable () async throws -> T) async rethrows -> T
}

extension SAESLoadingStateManager {
    func setLoadingState(_ state: SAESLoadingState) {
        self.loadingState = state
    }

    func performLoading<T>(
        _ operation: @escaping @Sendable () async throws -> T
    ) async rethrows -> T {
        setLoadingState(.loading)
        do {
            let result = try await operation()
            setLoadingState(.loaded)
            return result
        } catch {
            if let urlError = error as? URLError,
               [.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed].contains(urlError.code) {
                setLoadingState(.noNetwork)
            } else {
                setLoadingState(.error)
            }
            throw error
        }
    }
}
