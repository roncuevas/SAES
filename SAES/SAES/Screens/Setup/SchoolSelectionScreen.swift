import SwiftUI

@MainActor
struct SchoolSelectionScreen: View {
    @StateObject private var viewModel = SchoolSelectionViewModel()

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $viewModel.selectedType) {
                Text(Localization.university).tag(SchoolType.univeristy)
                Text(Localization.highSchool).tag(SchoolType.highSchool)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.isLoading {
                Spacer()
                LottieLoadingView()
                Spacer()
            } else {
                List(viewModel.currentSchools) { school in
                    SchoolCardView(
                        item: school,
                        status: viewModel.statuses[school.id],
                        onSelect: { viewModel.selectSchool(school) }
                    )
                }
                .listStyle(.plain)
            }
        }
        .task { await viewModel.loadSchools() }
        .task { await viewModel.loadStatuses() }
        .navigationBarTitle(
            title: Localization.selectYourSchool,
            titleDisplayMode: .inline,
            background: .visible,
            backButtonHidden: true
        )
    }
}
