import AppIntents
import SwiftUI
import WidgetKit

struct ScheduleWidget: Widget {
    let kind = "ScheduleWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectSchoolIntent.self,
            provider: ScheduleTimelineProvider()
        ) { entry in
            ScheduleWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Horario")
        .description("Ve tu horario de clases del dia.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
