import Foundation

final class ScheduleAvailabilityViewModel: SAESLoadingStateManager, ObservableObject {
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
        do {
            try await performLoading {
                let data = try await self.dataSource.fetch()
                self.viewStates = try self.statesParser.parse(data)
                self.values = try self.fieldsParser.getFields(data)

                for field in ScheduleAvailabilityField.allCases {
                    let value = try self.fieldsParser.getOptions(data: data, for: field)
                    await self.updateFields(field: field, value: value)
                }

                await self.updateSelectedField(field: .career, with: self.careers.first)
                await self.updateSelectedField(field: .studyPlan, with: self.studyPlans.first)
                await self.updateSelectedField(field: .shift, with: self.shifts.first)
                await self.updateSelectedField(field: .periods, with: self.periods.first)
            }
        } catch {
            print(error)
        }
    }

    func search() async {
        do {
            try await performLoading {
                var values = self.values
                values[.career] = self.selectedCareer?.value
                values[.studyPlan] = self.selectedStudyPlan?.value
                values[.periods] = self.selectedPeriod?.value
                values[.shift] = self.selectedShift?.value

                let data = try await self.dataSource.send(states: self.viewStates, values: values)
                let subjects = try self.fieldsParser.getSubjects(data: data)

                await self.updateSubjects(subjects)
            }
        } catch {
            print(error)
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

}
