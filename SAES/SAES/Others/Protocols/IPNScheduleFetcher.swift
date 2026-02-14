import Foundation

protocol IPNScheduleFetcher: Sendable {
    var networkClient: NetworkClient { get }
    func fetchIPNSchedule() async -> IPNScheduleResponse
}
