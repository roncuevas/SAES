import SwiftUI

struct TodayScheduleCardView: View {
    let item: TodayScheduleClassItem

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(item.color)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.timeRange)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(item.color)

                Text(item.materia)
                    .font(.headline)
                    .foregroundStyle(.primary)

                if let ubicacion = item.ubicacion {
                    Label {
                        Text(ubicacion)
                    } icon: {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }

                if !item.profesores.isEmpty {
                    Label {
                        Text("Prof. " + item.profesores)
                    } icon: {
                        Image(systemName: "person")
                            .font(.caption)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
}
