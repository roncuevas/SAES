import SwiftUI

struct TodayScheduleSectionView<Trailing: View>: View {
    let title: String
    let classes: [TodayScheduleClassItem]
    let onTapHeader: () -> Void
    @ViewBuilder let trailing: () -> Trailing

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(icon: "clock", title: title) {
                onTapHeader()
            } trailing: {
                trailing()
            }

            ForEach(classes) { item in
                TodayScheduleCardView(item: item)
            }
        }
    }
}

