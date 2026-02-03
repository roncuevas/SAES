import Foundation

extension IPNScheduleFetcher {
    var networkClient: NetworkClient {
        NetworkManager.shared
    }

    func fetchIPNSchedule() async -> IPNScheduleResponse {
        let scheduleURL = "https://api.roncuevas.com/ipn/schedule"
        do {
            return try await networkClient.sendRequest(url: scheduleURL,
                                                       type: IPNScheduleResponse.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "IPNScheduleFetcher")
        }
        return []
    }
}
