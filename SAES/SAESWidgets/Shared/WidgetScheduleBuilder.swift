import Foundation

struct WidgetClassItem: Identifiable {
    let id: String
    let materia: String
    let timeRange: String
    let profesores: String
    let ubicacion: String?
    let colorIndex: Int
    let startMinutes: Int
    let endMinutes: Int
}

enum WidgetScheduleBuilder {
    private static let dayKeys = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]

    static func buildClasses(from items: [ScheduleItem], for date: Date = Date()) -> (classes: [WidgetClassItem], dayName: String, isToday: Bool) {
        let horario = buildHorarioSemanal(from: items)
        guard let nearest = nearestDayKey(in: horario.horarioPorDia, from: date) else {
            return ([], "", false)
        }
        guard let materias = horario.horarioPorDia[nearest.dayKey] else {
            return ([], nearest.dayKey, nearest.isToday)
        }

        let allSubjects = Array(Set(items.map(\.materia))).sorted()
        var classes: [WidgetClassItem] = []

        for materia in materias {
            let colorIndex = allSubjects.firstIndex(of: materia.materia).map { $0 % 8 } ?? 0
            let scheduleItem = items.first { $0.materia == materia.materia }
            let profesores = scheduleItem?.profesores.capitalized ?? ""
            let ubicacion = buildUbicacion(scheduleItem)

            for rango in materia.horas {
                let startMin = rango.minutosDesdeMedianocheDe(rango.inicio)
                let endMin = rango.minutosDesdeMedianocheDe(rango.fin)
                classes.append(WidgetClassItem(
                    id: "\(materia.materia)_\(rango.inicio)_\(rango.fin)",
                    materia: materia.materia,
                    timeRange: "\(rango.inicio) - \(rango.fin)",
                    profesores: profesores,
                    ubicacion: ubicacion,
                    colorIndex: colorIndex,
                    startMinutes: startMin,
                    endMinutes: endMin
                ))
            }
        }

        classes.sort { $0.startMinutes < $1.startMinutes }
        return (classes, nearest.dayKey, nearest.isToday)
    }

    static func nextClass(from classes: [WidgetClassItem], at date: Date = Date()) -> WidgetClassItem? {
        let calendar = Calendar.current
        let nowMinutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        return classes.first { $0.endMinutes > nowMinutes } ?? classes.first
    }

    static func currentClass(from classes: [WidgetClassItem], at date: Date = Date()) -> WidgetClassItem? {
        let calendar = Calendar.current
        let nowMinutes = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
        return classes.first { $0.startMinutes <= nowMinutes && $0.endMinutes > nowMinutes }
    }

    // MARK: - Private

    private static func buildHorarioSemanal(from schedule: [ScheduleItem]) -> HorarioSemanal {
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

    private static func buildSalon(from item: ScheduleItem) -> String? {
        let parts = [item.edificio, item.salon].compactMap { $0?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private static func nearestDayKey(in horarioPorDia: [String: [MateriaConHoras]], from date: Date) -> (dayKey: String, isToday: Bool)? {
        let weekday = Calendar.current.component(.weekday, from: date)
        for offset in 0..<7 {
            let index = (weekday - 2 + offset + 7) % 7
            guard index < dayKeys.count else { continue }
            let dayKey = dayKeys[index]
            if let materias = horarioPorDia[dayKey], !materias.isEmpty {
                return (dayKey, offset == 0)
            }
        }
        return nil
    }

    private static func buildUbicacion(_ item: ScheduleItem?) -> String? {
        guard let item else { return nil }

        func clean(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespaces),
                  !trimmed.isEmpty, trimmed != "-" else { return nil }
            return trimmed
        }

        let parts = [
            clean(item.edificio).map { "Edificio \($0)" },
            clean(item.salon).map { "Salon \($0)" }
        ].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
