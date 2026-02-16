import Foundation

@MainActor
final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var schedule: [ScheduleItem] = []
    @Published var horarioSemanal = HorarioSemanal()
    @Published var pdfURL: URL?

    private var dataSource: SAESDataSource
    private var pdfDataSource: SAESDataSource
    private var parser: ScheduleParser
    private let logger: Logger

    init(dataSource: SAESDataSource = ScheduleDataSource(),
         pdfDataSource: SAESDataSource = SchedulePDFDataSource(),
         parser: ScheduleParser = ScheduleParser()) {
        self.dataSource = dataSource
        self.pdfDataSource = pdfDataSource
        self.parser = parser
        self.logger = Logger(logLevel: .info)
    }

    private var pdfTempURL: URL {
        let temporalDirectory = FileManager.default.temporaryDirectory
        return temporalDirectory.appendingPathComponent("comprobante", conformingTo: .pdf)
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

    func getPDFData() async {
        self.pdfURL = nil
        let pdfDataSource = self.pdfDataSource
        do {
            let data = try await performLoading {
                try await pdfDataSource.fetch()
            }
            let tempURL = try self.saveTemporalPDF(data: data)
            self.pdfURL = tempURL
        } catch {
            logger.log(level: .error, message: "\(error.localizedDescription)", source: "ScheduleViewModel")
        }
    }

    private func saveTemporalPDF(data: Data) throws -> URL {
        try data.write(to: pdfTempURL, options: .atomic)
        return pdfTempURL
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
