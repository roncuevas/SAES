import Foundation
import SwiftUI

struct UpcomingEventsView: View {
    let schedule: [IPNScheduleEvent]
    let maxEvents: Int

    var body: some View {
        if allEvents.isEmpty {
            Text(Localization.noUpcomingEvents)
                .foregroundStyle(.secondary)
        } else {
            VStack(spacing: 10) {
                ForEach(allEvents.prefix(maxEvents), id: \.self) { event in
                    EventCardView(event: event)
                }
            }
        }
    }

    private var allEvents: [IPNScheduleEvent] {
        schedule.validEvents
    }
}
