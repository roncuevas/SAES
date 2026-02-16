import Foundation

@MainActor
final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var schedule: [ScheduleItem] = []
    @Published var horarioSemanal = HorarioSemanal()

    private var dataSource: SAESDataSource
    private var parser: ScheduleParser
    private let logger: Logger

    init(dataSource: SAESDataSource = ScheduleDataSource(),
         parser: ScheduleParser = ScheduleParser()) {
        self.dataSource = dataSource
        self.parser = parser
        self.logger = Logger(logLevel: .info)
    }

    func getSchedule() async {
        let dataSource = self.dataSource
        let parser = self.parser
        do {
            let data = try await performLoading {
                try await dataSource.fetch()
            }
            let items = try parser.parseSchedule(data)
            self.schedule = items
            self.horarioSemanal = buildHorarioSemanal(from: items)
            if items.isEmpty {
                setLoadingState(.empty)
                logger.log(level: .warning, message: "Sin datos de horario", source: "ScheduleViewModel")
            } else {
                logger.log(level: .info, message: "Horario obtenido: \(items.count) materias", source: "ScheduleViewModel")
            }
        } catch {
            setLoadingState(.empty)
            logger.log(level: .error, message: "Error al obtener horario: \(error.localizedDescription)", source: "ScheduleViewModel")
        }
    }

    private func buildHorarioSemanal(from schedule: [ScheduleItem]) -> HorarioSemanal {
        var horario = HorarioSemanal()
        let dayNames = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"]
        for materia in schedule {
            for day in dayNames {
                if let value = materia[dynamicMember: day], !value.isEmpty {
                    horario.agregarMateria(dia: day.capitalized, materia: materia.materia, rangoHoras: value)
                }
            }
        }
        return horario
    }
}
