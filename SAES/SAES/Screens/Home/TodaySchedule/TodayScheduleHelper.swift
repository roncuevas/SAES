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

@MainActor
enum TodayScheduleHelper {
    static func todayDayKey() -> String? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        // Calendar weekday: 1=Sunday, 2=Monday, ..., 7=Saturday
        switch weekday {
        case 2: return "Lunes"
        case 3: return "Martes"
        case 4: return "Miercoles"
        case 5: return "Jueves"
        case 6: return "Viernes"
        case 7: return "Sabado"
        default: return nil
        }
    }

    static func todayClasses(from store: ScheduleStore) -> [TodayScheduleClassItem] {
        guard let dayKey = todayDayKey(),
              let materias = store.horarioSemanal.horarioPorDia[dayKey] else {
            return []
        }

        let allSubjects = store.scheduleItems.map(\.materia)

        return materias.flatMap { materia -> [TodayScheduleClassItem] in
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
