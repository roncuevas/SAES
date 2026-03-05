import SwiftUI
import WidgetKit

struct ScheduleWidget: Widget {
    let kind = "ScheduleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ScheduleTimelineProvider()) { entry in
            if #available(iOS 17.0, *) {
                ScheduleWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ScheduleWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Horario")
        .description("Ve tu horario de clases del dia.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
