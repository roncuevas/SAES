import SwiftUI

struct ServerStatusView: View {
    let schoolCode: String
    @State private var isOnline: Bool?

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .task(id: schoolCode) {
            isOnline = await ServerStatusService.fetchStatus(for: schoolCode)
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
