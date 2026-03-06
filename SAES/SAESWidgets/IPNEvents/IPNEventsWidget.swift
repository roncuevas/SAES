import SwiftUI
import WidgetKit

struct IPNEventsWidget: Widget {
    let kind = "IPNEventsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IPNEventsTimelineProvider()) { entry in
            IPNEventsWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Eventos IPN")
        .description("Proximos eventos del calendario IPN.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
