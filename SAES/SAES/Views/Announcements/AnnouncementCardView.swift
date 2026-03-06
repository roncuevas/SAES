import SwiftUI

struct AnnouncementCardView: View {
    let announcement: IPNAnnouncement
    @State private var showDetail = false

    private var isExpired: Bool { announcement.isExpired }
    private var accentColor: Color { isExpired ? .gray : announcement.tipo.color }
    private var isUrgent: Bool { announcement.tipo == .urgente && !isExpired }
    private var isHighImportance: Bool { announcement.importancia >= 7 && !isExpired }

    var body: some View {
        Button {
            showDetail = true
        } label: {
            HStack(spacing: 12) {
                iconView

                VStack(alignment: .leading, spacing: 6) {
                    Text(announcement.titulo)
                        .font(isUrgent ? .headline.weight(.bold) : .headline)
                        .foregroundStyle(isExpired ? .secondary : .primary)
                        .lineLimit(1)

                    Text(announcement.descripcion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack {
                        Label(announcement.formattedFecha, systemImage: "calendar")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(isUrgent ? accentColor : .secondary)
                        Spacer(minLength: 4)
                        Text(announcement.tipo.label)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(accentColor))
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUrgent ? accentColor.opacity(0.08) : Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isUrgent ? accentColor.opacity(0.4) : (isHighImportance ? accentColor.opacity(0.3) : Color(.separator)),
                        lineWidth: isUrgent || isHighImportance ? 1 : 0.5
                    )
            )
            .opacity(isExpired ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showDetail) {
            AnnouncementDetailSheet(announcement: announcement)
        }
    }

    // MARK: - Icon

    @ViewBuilder
    private var iconView: some View {
        if isUrgent {
            Image(systemName: announcement.tipo.icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(accentColor, in: Circle())
        } else {
            RoundedRectangle(cornerRadius: 2)
                .fill(accentColor)
                .frame(width: 4)
        }
    }
}
