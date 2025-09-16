import Foundation

final class ScheduleAvailabilityViewModel: ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle

    @Published var selectedCareer: SAESSelector?
    @Published var selectedStudyPlan: SAESSelector?
    @Published var selectedShift: SAESSelector?
    @Published var selectedPeriod: SAESSelector?

    @Published var careers: [SAESSelector] = []
    @Published var studyPlans: [SAESSelector] = []
    @Published var shifts: [SAESSelector] = []
    @Published var periods: [SAESSelector] = []

    @Published var subjects: [SAESScheduleSubject] = []

    private var dataSource = ScheduleAvailabilityDataSource()
    private var fieldsParser = ScheduleAvailabilityParser()
    private var statesParser = SAESViewStatesParser()
    private var viewStates: [SAESViewStates: String] = [:]
    private var values: [ScheduleAvailabilityField: String] = [:]

    func getData() async {
        await updateLoadingState(.loading)
        do {
            // Gets initial data
            let data = try await dataSource.fetch()
            self.viewStates = try statesParser.parse(data)
            self.values = try fieldsParser.getFields(data)

            // Fills the selects with their values
            for field in ScheduleAvailabilityField.allCases {
                let value = try fieldsParser.getOptions(data: data, for: field)
                await updateFields(field: field, value: value)
            }

            // Sets the selects with initial value
            await updateSelectedField(field: .career, with: careers.first)
            await updateSelectedField(field: .studyPlan, with: studyPlans.first)
            await updateSelectedField(field: .shift, with: shifts.first)
            await updateSelectedField(field: .periods, with: periods.first)

            await updateLoadingState(.loaded)
        } catch {
            print(error)
            await updateLoadingState(.error)
        }
    }

    func search() async {
        await updateLoadingState(.loading)
        do {
            var values = self.values
            values[.career] = selectedCareer?.value
            values[.studyPlan] = selectedStudyPlan?.value
            values[.periods] = selectedPeriod?.value
            values[.shift] = selectedShift?.value

            let data = try await dataSource.send(states: viewStates, values: values)
            let subjects = try fieldsParser.getSubjects(data: data)

            await updateSubjects(subjects)
            await updateLoadingState(.loaded)
        } catch {
            print(error)
            await updateLoadingState(.error)
        }
    }

    @MainActor
    func updateSelectedField(field: ScheduleAvailabilityField, with value: SAESSelector?) {
        switch field {
        case .career:
            self.selectedCareer = value
        case .shift:
            self.selectedShift = value
        case .periods:
            self.selectedPeriod = value
        case .studyPlan:
            self.selectedStudyPlan = value
        case .schoolPeriodGroup, .sequences, .visualize:
            break
        }
    }

    @MainActor
    func updateFields(field: ScheduleAvailabilityField, value: [SAESSelector]) {
        switch field {
        case .career:
            self.careers = value
        case .shift:
            self.shifts = value
        case .periods:
            self.periods = value
        case .studyPlan:
            self.studyPlans = value
        case .schoolPeriodGroup, .sequences, .visualize:
            break
        }
    }

    @MainActor
    func updateSubjects(_ subjects: [SAESScheduleSubject]) {
        self.subjects = subjects
    }

    @MainActor
    func updateLoadingState(_ state: SAESLoadingState) {
        self.loadingState = state
    }
}
