import Foundation
import SwiftUI

struct UpcomingEventsView: View {
    let schedule: [IPNScheduleModel]
    let maxEvents: Int

    var body: some View {
        if allEvents.isEmpty {
            Text(Localization.noUpcomingEvents)
                .foregroundStyle(.secondary)
        } else {
            ForEach(allEvents.prefix(maxEvents), id: \.self) { event in
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.type.eventEmoji.space + event.name)
                            .fontWeight(.semibold)
                        Text(event.dateRange.toStringInterval)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
    }

    private var allEvents: [IPNScheduleEvent] {
        schedule.flatMap { $0.events }.validEvents
    }
}
