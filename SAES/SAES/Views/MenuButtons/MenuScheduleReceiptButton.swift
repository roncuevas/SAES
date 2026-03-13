import SwiftUI

struct MenuScheduleReceiptButton: View {
    @ObservedObject private var scheduleReceiptManager = ScheduleReceiptManager.shared

    var body: some View {
        Button {
            scheduleReceiptManager.showCachedPDF()
        } label: {
            Label(Localization.scheduleReceipt, systemImage: ScheduleReceiptManager.icon)
                .tint(.saes)
        }
    }
}
