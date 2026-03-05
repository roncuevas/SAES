import SwiftUI
import WidgetKit

@main
struct SAESWidgetBundle: WidgetBundle {
    var body: some Widget {
        ScheduleWidget()
        IPNEventsWidget()
    }
}
