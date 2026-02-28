import SwiftUI

struct ScholarshipDetailSheet: View {
    let scholarship: IPNScholarship
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            detailRow(
                icon: "text.alignleft",
                tint: .gray,
                label: Localization.subjects,
                value: scholarship.descripcion,
                lineLimit: nil
            )
            detailRow(
                icon: "calendar",
                tint: .orange,
                label: Localization.date,
                value: scholarship.fechaLabel
            )
            detailRow(
                icon: "banknote",
                tint: .green,
                label: Localization.amount,
                value: scholarship.monto
            )
            if let periodicidad = scholarship.periodicidad {
                detailRow(
                    icon: "arrow.trianglehead.2.counterclockwise",
                    tint: .blue,
                    label: Localization.frequency,
                    value: periodicidad.label
                )
            }
            detailRow(
                icon: "gift",
                tint: .purple,
                label: Localization.benefitType,
                value: scholarship.tipoBeneficio.label
            )

            Spacer()

            actionButtons
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 16)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(scholarship.titulo)
                    .font(.title3)
                    .bold()
                Text(scholarship.status.label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(scholarship.status.color))
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

    // MARK: - Action buttons

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                if let url = URL(string: scholarship.url ?? "https://www.ipn.mx/becas/") {
                    openURL(url)
                }
            } label: {
                HStack {
                    Image(systemName: "safari")
                    Text(Localization.moreInfo)
                }
                .font(.body.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(Capsule().fill(Color.saes))
            }

            if let convocatoriaUrl = scholarship.convocatoriaUrl,
               let url = URL(string: convocatoriaUrl) {
                Button {
                    openURL(url)
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text(Localization.viewCall)
                    }
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.saes)
                    .background(
                        Capsule()
                            .stroke(Color.saes, lineWidth: 1.5)
                    )
                }
            }
        }
    }
}
