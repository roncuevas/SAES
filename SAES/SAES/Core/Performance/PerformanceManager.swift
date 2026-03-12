import Foundation
@preconcurrency import FirebasePerformance

actor PerformanceManager {
    static let shared = PerformanceManager()
    private var activeTraces: [String: Trace] = [:]
    private init() {}

    func startTrace(name: String, attributes: [String: String] = [:]) {
        guard let trace = Performance.startTrace(name: name) else { return }
        for (key, value) in attributes {
            trace.setValue(value, forAttribute: key)
        }
        activeTraces[name] = trace
    }

    func stopTrace(name: String) {
        guard let trace = activeTraces.removeValue(forKey: name) else { return }
        trace.stop()
    }

    func measure<T: Sendable>(
        name: String,
        attributes: [String: String] = [:],
        operation: @Sendable () async throws -> T
    ) async rethrows -> T {
        startTrace(name: name, attributes: attributes)
        do {
            let result = try await operation()
            stopTrace(name: name)
            return result
        } catch {
            stopTrace(name: name)
            throw error
        }
    }
}
