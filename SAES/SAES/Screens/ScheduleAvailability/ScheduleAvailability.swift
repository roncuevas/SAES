import SwiftUI

struct ScheduleAvailability: View {
    private var viewModel = ScheduleAvailabilityViewModel()

    var body: some View {
        Color.clear
            .task {
                await viewModel.getData()
            }
    }
}
