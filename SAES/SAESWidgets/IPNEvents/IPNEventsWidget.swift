import SwiftUI
import WidgetKit

struct IPNEventsWidget: Widget {
    let kind = "IPNEventsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IPNEventsTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                IPNEventsWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                IPNEventsWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Eventos IPN")
        .description("Proximos eventos del calendario IPN.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
