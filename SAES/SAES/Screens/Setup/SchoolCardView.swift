import SwiftUI

struct SchoolCardView: View {
    let item: SchoolDisplayItem
    let status: Bool??
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.abbreviation)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    if item.name != item.abbreviation {
                        Text(item.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }

                Spacer()

                statusIndicator
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var statusIndicator: some View {
        if let outerStatus = status {
            if let isOnline = outerStatus {
                HStack(spacing: 4) {
                    Circle()
                        .fill(isOnline ? .green : .red)
                        .frame(width: 8, height: 8)
                    Text(isOnline ? Localization.online : Localization.offline)
                        .font(.caption2)
                        .foregroundStyle(isOnline ? .green : .red)
                }
            } else {
                ProgressView()
                    .controlSize(.mini)
            }
        } else {
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 8, height: 8)
        }
    }
}
