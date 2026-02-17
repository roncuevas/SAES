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
                    detailRow(icon: "person", text: "Prof. " + item.profesores.capitalized)
                    detailRow(icon: "person.2", text: Localization.group.colon.space + item.grupo)
                    if let ubicacion = buildUbicacion(item) {
                        detailRow(icon: "mappin.and.ellipse", text: ubicacion)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func detailRow(icon: String, text: String) -> some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: icon)
                .font(.caption)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
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
