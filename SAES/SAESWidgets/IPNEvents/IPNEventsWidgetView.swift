import SwiftUI
import WidgetKit

struct IPNEventsWidgetView: View {
    let entry: IPNEventsEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        default:
            smallView
        }
    }

    // MARK: - Small: Next event

    @ViewBuilder
    private var smallView: some View {
        if entry.isEmpty {
            WidgetEmptyView(icon: "calendar", message: "No hay eventos proximos")
        } else if let event = entry.events.first {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("IPN")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.saes, in: Capsule())
                    Spacer()
                }

                if let month = event.monthAbbreviation,
                   let day = event.dayString {
                    HStack(spacing: 8) {
                        VStack(spacing: 1) {
                            Text(month)
                                .font(.caption2.weight(.semibold))
                            Text(day)
                                .font(.title3.weight(.bold))
                        }
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.saes, in: RoundedRectangle(cornerRadius: 8))

                        Text(event.name)
                            .font(.caption.weight(.medium))
                            .lineLimit(3)
                    }
                }

                Spacer(minLength: 0)
            }
        } else {
            WidgetEmptyView(icon: "calendar", message: "No hay eventos proximos")
        }
    }

    // MARK: - Medium: List of events

    @ViewBuilder
    private var mediumView: some View {
        if entry.isEmpty {
            WidgetEmptyView(icon: "calendar", message: "No hay eventos proximos")
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Eventos IPN")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(entry.events.count) proximos")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 8)

                ForEach(entry.events.prefix(4), id: \.self) { event in
                    HStack(spacing: 10) {
                        if let month = event.monthAbbreviation,
                           let day = event.dayString {
                            VStack(spacing: 1) {
                                Text(month)
                                    .font(.system(size: 8, weight: .semibold))
                                Text(day)
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color.saes, in: RoundedRectangle(cornerRadius: 6))
                        }

                        VStack(alignment: .leading, spacing: 1) {
                            Text(event.name)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                            Text(event.toStringInterval)
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 3)
                }
            }
            .padding(2)
        }
    }
}
