import SwiftUI

struct AnnouncementCardView: View {
    let announcement: IPNAnnouncement
    @State private var showDetail = false

    private var isExpired: Bool { announcement.isExpired }
    private var accentColor: Color { isExpired ? .gray : announcement.tipo.color }

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(announcement.titulo)
                            .font(.headline)
                            .foregroundStyle(isExpired ? .secondary : .primary)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(announcement.tipo.label)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(accentColor))
                    }

                    Text(announcement.descripcion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        Label(announcement.formattedFecha, systemImage: "calendar")
                        Spacer(minLength: 0)
                        if let escuelas = announcement.escuelas, !escuelas.isEmpty {
                            Label(escuelas.joined(separator: ", "), systemImage: "building.2")
                                .lineLimit(1)
                        }
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(accentColor)
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
            .opacity(isExpired ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showDetail) {
            AnnouncementDetailSheet(announcement: announcement)
        }
    }
}
