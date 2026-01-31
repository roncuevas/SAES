import Foundation

extension IPNScheduleFetcher {
    func fetchIPNSchedule() async -> IPNScheduleResponse {
        let scheduleURL = "https://api.roncuevas.com/ipn/schedule"
        do {
            return try await NetworkManager.shared.sendRequest(url: scheduleURL,
                                                               type: IPNScheduleResponse.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "IPNScheduleFetcher")
        }
        return []
    }
}
