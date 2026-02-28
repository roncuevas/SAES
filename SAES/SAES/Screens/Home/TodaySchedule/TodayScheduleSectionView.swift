import SwiftUI

struct TodayScheduleSectionView: View {
    let title: String
    let classes: [TodayScheduleClassItem]
    let onTapHeader: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HomeSectionHeader(icon: "clock", title: title) {
                onTapHeader()
            } trailing: {
                Text(classCountLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(.saes))
            }

            ForEach(classes) { item in
                TodayScheduleCardView(item: item)
            }
        }
    }

    private var classCountLabel: String {
        let count = classes.count
        let label = count == 1 ? Localization.classLabel : Localization.classesLabel
        return "\(count) \(label)"
    }
}
