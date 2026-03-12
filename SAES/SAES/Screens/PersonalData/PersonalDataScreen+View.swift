import SwiftUI

extension PersonalDataScreen: View {
    var body: some View {
        content
            .screenTrace("personal_data")
            .appErrorOverlay(isDataLoaded: !viewModel.personalData.isEmpty)
            .profilePicturePreview(imageData: viewModel.profilePicture, isPresented: $showProfilePicturePreview)
            .task {
                await AnalyticsManager.shared.logScreen("personalData")
                guard viewModel.personalData.isEmpty
                else { return }
                await viewModel.getData(refresh: false)
                await viewModel.getProfilePicture()
            }
            .refreshable {
                await viewModel.getData(refresh: true)
            }
    }

    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForPersonalData,
            retryAction: { Task { await viewModel.getData(refresh: true) } }
        ) {
            loadedContent
        }
    }

    private var loadedContent: some View {
        ZStack(alignment: .bottomTrailing) {
            dataList
            fabButton
        }
    }

    @ViewBuilder
    private var dataList: some View {
        if #available(iOS 17, *) {
            listContent
                .listSectionSpacing(8)
        } else {
            listContent
        }
    }

    private var listContent: some View {
        List {
            PersonalDataListContent(
                data: viewModel.personalData,
                profilePicture: viewModel.profilePicture,
                onAvatarTap: { showProfilePicturePreview = true }
            )
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - FAB

    private var fabButton: some View {
        FloatingToggleButton(systemImage: "qrcode") {
            router.navigateTo(AppDestination.credential)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

}
