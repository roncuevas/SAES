import Combine

protocol SAESLoadingStateManager: ObservableObject {
    var loadingState: SAESLoadingState { get set }
    @MainActor func setLoadingState(_ state: SAESLoadingState)
    func performLoading<T>(_ operation: @escaping () async throws -> T) async rethrows -> T
}

extension SAESLoadingStateManager {
    @MainActor
    func setLoadingState(_ state: SAESLoadingState) {
        self.loadingState = state
    }

    func performLoading<T>(
        _ operation: @escaping () async throws -> T
    ) async rethrows -> T {
        await setLoadingState(.loading)
        do {
            let result = try await operation()
            await setLoadingState(.loaded)
            return result
        } catch {
            await setLoadingState(.error)
            throw error
        }
    }
}
