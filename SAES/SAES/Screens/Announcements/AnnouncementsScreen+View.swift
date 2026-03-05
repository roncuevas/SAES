import SwiftUI

extension AnnouncementsScreen: View {
    var body: some View {
        content
            .navigationTitle(Localization.announcements)
            .searchable(
                text: $viewModel.searchText,
                prompt: Localization.searchAnnouncements
            )
            .task {
                await AnalyticsManager.shared.logScreen("announcements")
                guard viewModel.announcements.isEmpty else { return }
                await viewModel.getAnnouncements()
            }
            .refreshable {
                await viewModel.getAnnouncements()
            }
    }

    @ViewBuilder
    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForAnnouncements,
            retryAction: { Task { await viewModel.getAnnouncements() } }
        ) {
            announcementsContent
        }
    }

    private var announcementsContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                filterBar
                LazyVStack(spacing: 10) {
                    ForEach(viewModel.filteredAnnouncements) { announcement in
                        AnnouncementCardView(announcement: announcement)
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Filter bar

    private var filterBar: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                typeFilterChip
                schoolFilterChip
                sortChip
            }
        }
        .scrollIndicators(.hidden)
    }

    private var typeFilterChip: some View {
        Menu {
            Button {
                viewModel.selectedType = nil
            } label: {
                Label(Localization.allTypes, systemImage: viewModel.selectedType == nil ? "checkmark" : "")
            }
            ForEach(IPNAnnouncementType.allCases, id: \.self) { type in
                Button {
                    viewModel.selectedType = type
                } label: {
                    Label(type.label, systemImage: viewModel.selectedType == type ? "checkmark" : "")
                }
            }
        } label: {
            chipLabel(
                icon: "line.3.horizontal.decrease.circle",
                text: viewModel.selectedType?.label ?? Localization.allTypes,
                isActive: viewModel.selectedType != nil
            )
        }
    }

    private var schoolFilterChip: some View {
        Button {
            viewModel.filterMySchool.toggle()
        } label: {
            chipLabel(
                icon: "building.2",
                text: viewModel.filterMySchool ? Localization.mySchool : Localization.allSchools,
                isActive: viewModel.filterMySchool
            )
        }
    }

    private var sortChip: some View {
        Button {
            viewModel.newestFirst.toggle()
        } label: {
            chipLabel(
                icon: viewModel.newestFirst ? "arrow.down" : "arrow.up",
                text: viewModel.newestFirst ? Localization.recent : Localization.date,
                isActive: false
            )
        }
    }

    private func chipLabel(icon: String, text: String, isActive: Bool) -> some View {
        Label(text, systemImage: icon)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(isActive ? .white : .primary)
            .background(
                Capsule().fill(isActive ? Color.saes : Color(.tertiarySystemGroupedBackground))
            )
    }
}
