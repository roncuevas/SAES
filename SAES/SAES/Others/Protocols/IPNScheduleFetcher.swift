import Foundation

protocol IPNScheduleFetcher {
    var networkClient: NetworkClient { get }
    func fetchIPNSchedule() async -> IPNScheduleResponse
}
