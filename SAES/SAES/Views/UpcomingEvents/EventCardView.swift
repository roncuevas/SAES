import SwiftUI

struct EventCardView: View {
    let event: IPNScheduleEvent

    var body: some View {
        HStack(spacing: 12) {
            dateBadge
            eventDetails
        }
    }

    @ViewBuilder
    private var dateBadge: some View {
        if let startDate = event.startDate {
            VStack(spacing: 2) {
                Text(monthText(from: startDate))
                    .font(.caption2.weight(.semibold))
                Text(dayText(from: startDate))
                    .font(.title2.weight(.bold))
            }
            .foregroundStyle(.white)
            .frame(width: 48, height: 48)
            .background(Color.saes, in: RoundedRectangle(cornerRadius: 10))
            .accessibilityElement(children: .combine)
        }
    }

    private var eventDetails: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(event.name)
                .fontWeight(.semibold)
                .lineLimit(2)
            Text(event.toStringInterval)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter
    }()

    private func monthText(from date: Date) -> String {
        Self.monthFormatter.string(from: date).uppercased()
    }

    private func dayText(from date: Date) -> String {
        "\(Calendar.current.component(.day, from: date))"
    }
}
