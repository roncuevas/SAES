import SwiftUI

struct TodayScheduleSectionView: View {
    let title: String
    let classes: [TodayScheduleClassItem]
    let onTapHeader: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(icon: "clock", title: title) {
                onTapHeader()
            }

            ForEach(classes) { item in
                TodayScheduleCardView(item: item)
            }
        }
    }
}
