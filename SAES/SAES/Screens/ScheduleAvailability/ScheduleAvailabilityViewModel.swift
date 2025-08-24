import Foundation

final class ScheduleAvailabilityViewModel: ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle
    private var dataSource = ScheduleAvailabilityDataSource()
    private var parser = ScheduleAvailabilityParser()
    private var statesParser = SAESViewStatesParser()

    func getData() async {
        do {
            let data = try await dataSource.fetch()
            let viewStates = try statesParser.parse(data)
            let values = try parser.getFields(data)
            try await dataSource.send(states: viewStates, values: values)
        } catch {
            print(error)
        }
    }
}
