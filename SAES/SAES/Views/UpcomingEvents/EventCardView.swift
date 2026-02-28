import SwiftUI

struct EventCardView: View {
    let event: IPNScheduleEvent

    var body: some View {
        HStack(spacing: 12) {
            dateBadge
            eventDetails
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var dateBadge: some View {
        if let month = event.monthAbbreviation,
           let day = event.dayString {
            VStack(spacing: 2) {
                Text(month)
                    .font(.caption2.weight(.semibold))
                Text(day)
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
                .font(.subheadline.weight(.bold))
                .lineLimit(2)
            Text(event.toStringInterval)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
