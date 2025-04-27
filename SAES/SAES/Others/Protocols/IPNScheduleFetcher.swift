import Foundation

protocol IPNScheduleFetcher {
    func fetchIPNSchedule() async -> IPNScheduleResponse
}
