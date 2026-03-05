import SwiftUI

struct AnnouncementDetailSheet: View {
    let announcement: IPNAnnouncement
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    detailRow(
                        icon: "text.alignleft",
                        tint: .gray,
                        label: Localization.description,
                        value: announcement.descripcion,
                        lineLimit: nil
                    )
                    detailRow(
                        icon: "tag",
                        tint: announcement.tipo.color,
                        label: Localization.type,
                        value: announcement.tipo.label
                    )
                    detailRow(
                        icon: "calendar",
                        tint: .orange,
                        label: Localization.date,
                        value: announcement.formattedFecha
                    )
                    if let expira = announcement.formattedExpira {
                        detailRow(
                            icon: "clock",
                            tint: .red,
                            label: Localization.expires,
                            value: expira
                        )
                    }
                    if let escuelas = announcement.escuelas, !escuelas.isEmpty {
                        detailRow(
                            icon: "building.2",
                            tint: .blue,
                            label: Localization.schools,
                            value: escuelas.joined(separator: ", ")
                        )
                    }
                    if let nivel = announcement.nivel {
                        detailRow(
                            icon: "graduationcap",
                            tint: .purple,
                            label: Localization.level,
                            value: nivel
                        )
                    }
                }
                .padding(.horizontal, 20)
            }

            if announcement.url != nil {
                actionButton
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(announcement.titulo)
                    .font(.title3)
                    .bold()
                Text(announcement.tipo.label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(announcement.tipo.color))
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
            .accessibilityLabel(Text("Close", comment: "Dismiss button"))
        }
    }

    // MARK: - Detail row

    private func detailRow(
        icon: String,
        tint: Color,
        label: String,
        value: String,
        lineLimit: Int? = 1
    ) -> some View {
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
                    .lineLimit(lineLimit)
            }
        }
    }

    // MARK: - Action button

    private var actionButton: some View {
        Button {
            if let urlString = announcement.url, let url = URL(string: urlString) {
                openURL(url)
            }
        } label: {
            HStack {
                Image(systemName: "safari")
                Text(Localization.openAnnouncement)
            }
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(Capsule().fill(Color.saes))
        }
    }
}
