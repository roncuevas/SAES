import SwiftUI

struct TodayScheduleClassItem: Identifiable {
    let id: String
    let materia: String
    let timeRange: String
    let profesores: String
    let ubicacion: String?
    let color: Color
    let startMinutes: Int
}

struct TodayScheduleResult {
    let classes: [TodayScheduleClassItem]
    let isToday: Bool
    let dayKey: String
}

@MainActor
enum TodayScheduleHelper {
    private static let dayKeys = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]

    static func nearestDayKey(in horarioPorDia: [String: [MateriaConHoras]]) -> (dayKey: String, isToday: Bool)? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
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

    static func todayClasses(from store: ScheduleStore) -> TodayScheduleResult? {
        guard let nearest = nearestDayKey(in: store.horarioSemanal.horarioPorDia),
              let materias = store.horarioSemanal.horarioPorDia[nearest.dayKey] else {
            return nil
        }

        let allSubjects = store.scheduleItems.map(\.materia)

        let classes = materias.flatMap { materia -> [TodayScheduleClassItem] in
            let color = SubjectColorProvider.color(for: materia.materia, in: allSubjects)
            let scheduleItem = store.scheduleItems.first { $0.materia == materia.materia }
            let profesores = scheduleItem?.profesores.capitalized ?? ""
            let ubicacion = buildUbicacion(scheduleItem)

            return materia.horas.map { rango in
                TodayScheduleClassItem(
                    id: "\(materia.materia)_\(rango.inicio)_\(rango.fin)",
                    materia: materia.materia,
                    timeRange: rango.inicio + " - " + rango.fin,
                    profesores: profesores,
                    ubicacion: ubicacion,
                    color: color,
                    startMinutes: rango.minutosDesdeMedianocheDe(rango.inicio)
                )
            }
        }
        .sorted { $0.startMinutes < $1.startMinutes }

        guard !classes.isEmpty else { return nil }
        return TodayScheduleResult(classes: classes, isToday: nearest.isToday, dayKey: nearest.dayKey)
    }

    private static func buildUbicacion(_ item: ScheduleItem?) -> String? {
        guard let item else { return nil }

        func clean(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespaces),
                  !trimmed.isEmpty, trimmed != "-" else { return nil }
            return trimmed
        }

        let parts = [
            clean(item.edificio).map { Localization.building.space + $0 },
            clean(item.salon).map { Localization.classroom.space + $0 }
        ].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
