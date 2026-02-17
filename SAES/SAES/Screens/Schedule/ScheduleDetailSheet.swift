import SwiftUI

struct ScheduleDetailSheet: View {
    let block: ScheduleGridBlock
    let scheduleItem: ScheduleItem?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            if let item = scheduleItem {
                detailRow(icon: "person.2.fill", tint: .blue, label: Localization.group, value: item.grupo)
                detailRow(icon: "person.fill", tint: .purple, label: Localization.teacher, value: item.profesores)
                detailRow(icon: "clock.fill", tint: .green, label: Localization.timetable, value: scheduleString(for: item))
                if let edificio = item.edificio, !edificio.trimmingCharacters(in: .whitespaces).isEmpty {
                    detailRow(icon: "building.2.fill", tint: .orange, label: Localization.building, value: edificio)
                }
                if let salon = item.salon, !salon.trimmingCharacters(in: .whitespaces).isEmpty {
                    detailRow(icon: "door.left.hand.open", tint: .red, label: Localization.classroom, value: salon)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            HStack(spacing: 10) {
                Circle()
                    .fill(block.color)
                    .frame(width: 14, height: 14)
                Text(block.materia.localizedCapitalized)
                    .font(.title3)
                    .bold()
            }
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
    }

    // MARK: - Detail row

    private func detailRow(icon: String, tint: Color, label: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(tint)
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.15), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }

    // MARK: - Schedule string

    private func scheduleString(for item: ScheduleItem) -> String {
        let dayKeys = ["lunes", "martes", "miercoles", "jueves", "viernes", "sabado"]
        let shortNames: [SAESDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]

        let activeDays = zip(dayKeys, shortNames).compactMap { key, day -> String? in
            guard let value = item[dynamicMember: key], !value.isEmpty else { return nil }
            return day.shortName
        }

        let days = activeDays.joined(separator: ", ")
        return "\(days) \u{00B7} \(block.inicio) - \(block.fin)"
    }
}
