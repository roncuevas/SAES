import Foundation

extension IPNScheduleFetcher {
    var networkClient: NetworkClient {
        NetworkManager.shared
    }

    func fetchIPNSchedule() async -> IPNScheduleResponse {
        do {
            return try await networkClient.sendRequest(url: URLConstants.ipnSchedule,
                                                       type: IPNScheduleResponse.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "IPNScheduleFetcher")
        }
        return []
    }
}
