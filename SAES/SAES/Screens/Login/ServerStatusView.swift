import SwiftUI

struct ServerStatusView: View {
    let isOnline: Bool?

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var statusColor: Color {
        switch isOnline {
        case .some(true): return .green
        case .some(false): return .red
        case .none: return .gray
        }
    }

    private var statusText: String {
        switch isOnline {
        case .some(true): return Localization.serverAvailable
        case .some(false): return Localization.serverUnavailable
        case .none: return Localization.checkingServer
        }
    }
}
