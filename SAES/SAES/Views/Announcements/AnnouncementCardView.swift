import SwiftUI

struct AnnouncementCardView: View {
    let announcement: IPNAnnouncement
    @State private var showDetail = false

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(announcement.tipo.color)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(announcement.titulo)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(announcement.tipo.label)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(announcement.tipo.color))
                    }

                    Text(announcement.descripcion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        Label(announcement.fecha, systemImage: "calendar")
                        Spacer(minLength: 0)
                        if let escuelas = announcement.escuelas, !escuelas.isEmpty {
                            Label(escuelas.joined(separator: ", "), systemImage: "building.2")
                                .lineLimit(1)
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(announcement.tipo.color)
                    .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showDetail) {
            AnnouncementDetailSheet(announcement: announcement)
        }
    }
}
