import Foundation

@MainActor
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

    private var dataSource: ScheduleAvailabilityDataSource
    private var fieldsParser: ScheduleAvailabilityParser
    private var statesParser: SAESViewStatesParser
    private var viewStates: [SAESViewStates: String] = [:]
    private var values: [ScheduleAvailabilityField: String] = [:]
    private let logger: Logger

    init(dataSource: ScheduleAvailabilityDataSource = ScheduleAvailabilityDataSource(),
         fieldsParser: ScheduleAvailabilityParser = ScheduleAvailabilityParser(),
         statesParser: SAESViewStatesParser = SAESViewStatesParser()) {
        self.dataSource = dataSource
        self.fieldsParser = fieldsParser
        self.statesParser = statesParser
        self.logger = Logger(logLevel: .error)
    }

    func getData() async {
        let dataSource = self.dataSource
        let statesParser = self.statesParser
        let fieldsParser = self.fieldsParser
        do {
            let data = try await performLoading {
                try await dataSource.fetch()
            }
            self.viewStates = try statesParser.parse(data)
            self.values = try fieldsParser.getFields(data)

            for field in ScheduleAvailabilityField.allCases {
                let value = try fieldsParser.getOptions(data: data, for: field)
                self.updateFields(field: field, value: value)
            }

            self.updateSelectedField(field: .career, with: self.careers.first)
            self.updateSelectedField(field: .studyPlan, with: self.studyPlans.first)
            self.updateSelectedField(field: .shift, with: self.shifts.first)
            self.updateSelectedField(field: .periods, with: self.periods.first)
        } catch {
            logger.log(level: .error, message: "\(error)", source: "ScheduleAvailabilityViewModel")
        }
    }

    func search() async {
        let dataSource = self.dataSource
        let fieldsParser = self.fieldsParser
        var capturedValues = self.values
        capturedValues[.career] = self.selectedCareer?.value
        capturedValues[.studyPlan] = self.selectedStudyPlan?.value
        capturedValues[.periods] = self.selectedPeriod?.value
        capturedValues[.shift] = self.selectedShift?.value
        let finalValues = capturedValues
        let viewStates = self.viewStates
        do {
            let data = try await performLoading {
                try await dataSource.send(states: viewStates, values: finalValues)
            }
            let subjects = try fieldsParser.getSubjects(data: data)
            self.subjects = subjects
        } catch {
            logger.log(level: .error, message: "\(error)", source: "ScheduleAvailabilityViewModel")
        }
    }

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

    func updateSubjects(_ subjects: [SAESScheduleSubject]) {
        self.subjects = subjects
    }

}
