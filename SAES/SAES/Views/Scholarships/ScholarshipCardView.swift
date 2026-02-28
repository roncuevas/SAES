import SwiftUI

struct ScholarshipCardView: View {
    @Environment(\.openURL) private var openURL
    let scholarship: IPNScholarship

    var body: some View {
        Button {
            if let url = URL(string: "https://www.ipn.mx/becas/") {
                openURL(url)
            }
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(scholarship.status.color)
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(scholarship.titulo)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        Text(scholarship.status.label)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Capsule().fill(scholarship.status.color))
                    }

                    Text(scholarship.descripcion)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 12) {
                        Label(scholarship.fechaLabel, systemImage: "calendar")
                        Spacer(minLength: 0)
                        Label(scholarship.monto, systemImage: "banknote")
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(scholarship.status.color)
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
    }
}
