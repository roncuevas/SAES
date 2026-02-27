import Foundation
import SwiftUI

@MainActor
final class ScheduleViewModel: SAESLoadingStateManager, ObservableObject {
    @Published var loadingState: SAESLoadingState = .idle
    @Published var schedule: [ScheduleItem] = []
    @Published var horarioSemanal = HorarioSemanal()
    @Published var viewMode: ScheduleViewMode = .list
    @Published private(set) var gridBlocks: [ScheduleGridBlock] = []
    @Published private(set) var subjectColors: [(materia: String, color: Color)] = []
    @Published private(set) var gridStartHour: Int = 7
    @Published private(set) var gridEndHour: Int = 18
    @Published private(set) var hasSaturdayClasses: Bool = false

    private var dataSource: SAESDataSource
    private var parser: ScheduleParser
    private let logger: Logger

    init(dataSource: SAESDataSource = ScheduleDataSource(),
         parser: ScheduleParser = ScheduleParser()) {
        self.dataSource = dataSource
        self.parser = parser
        self.logger = Logger(logLevel: .info)
    }

    // MARK: - Data loading

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
            ScheduleStore.shared.update(items: items, horario: self.horarioSemanal)
            rebuildGridData()
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

    private func rebuildGridData() {
        let allSubjects = Array(Set(schedule.map(\.materia))).sorted()
        subjectColors = SubjectColorProvider.colors(for: allSubjects)
        hasSaturdayClasses = horarioSemanal.horarioPorDia["Sabado"]?.isEmpty == false

        let dayKeys = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
        var blocks: [ScheduleGridBlock] = []
        for (dayIndex, dayKey) in dayKeys.enumerated() {
            guard let materias = horarioSemanal.horarioPorDia[dayKey] else { continue }
            for materia in materias {
                let color = SubjectColorProvider.color(for: materia.materia, in: allSubjects)
                for rango in materia.horas where rango.inicio.contains(":") && rango.fin.contains(":") {
                    blocks.append(ScheduleGridBlock(
                        materia: materia.materia,
                        salon: materia.salon,
                        inicio: rango.inicio,
                        fin: rango.fin,
                        dayIndex: dayIndex,
                        color: color
                    ))
                }
            }
        }
        gridBlocks = blocks

        let startMinutes = blocks.map(\.inicioMinutos)
        let endMinutes = blocks.map(\.finMinutos)
        gridStartHour = startMinutes.min().map { $0 / 60 } ?? 7
        gridEndHour = endMinutes.max().map { ($0 + 59) / 60 } ?? 18
    }

    // MARK: - Lookup

    func scheduleItem(for materia: String) -> ScheduleItem? {
        schedule.first { $0.materia == materia }
    }

    func color(for materia: String) -> Color {
        let allSubjects = schedule.map(\.materia)
        return SubjectColorProvider.color(for: materia, in: allSubjects)
    }

    private func buildHorarioSemanal(from schedule: [ScheduleItem]) -> HorarioSemanal {
        var horario = HorarioSemanal()
        let dayNames = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"]
        for materia in schedule {
            let salon = buildSalon(from: materia)
            for day in dayNames {
                if let value = materia[dynamicMember: day], !value.isEmpty {
                    horario.agregarMateria(dia: day.capitalized, materia: materia.materia, rangoHoras: value, salon: salon)
                }
            }
        }
        return horario
    }

    private func buildSalon(from item: ScheduleItem) -> String? {
        let parts = [item.edificio, item.salon].compactMap { $0?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
