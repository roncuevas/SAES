import SwiftUI

struct ScheduleListRowView: View {
    let materia: MateriaConHoras
    let scheduleItem: ScheduleItem?
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                ForEach(materia.horas, id: \.inicio) { rango in
                    Text(rango.inicio + " - " + rango.fin)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(materia.materia)
                    .font(.headline)

                if let item = scheduleItem {
                    Label("Prof. " + item.profesores.capitalized, systemImage: "person")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Label(Localization.group.colon.space + item.grupo, systemImage: "person.2")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let ubicacion = buildUbicacion(item) {
                        Label(ubicacion, systemImage: "mappin.and.ellipse")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func buildUbicacion(_ item: ScheduleItem) -> String? {
        func clean(_ value: String?) -> String? {
            guard let trimmed = value?.trimmingCharacters(in: .whitespaces),
                  !trimmed.isEmpty, trimmed != "-" else { return nil }
            return trimmed
        }

        let parts = [
            clean(item.edificio).map { Localization.building.space + $0 },
            clean(item.salon).map { Localization.classroom.space + $0 },
        ].compactMap { $0 }

        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
