@preconcurrency import FirebaseRemoteConfig
import Foundation
import Navigation
import SwiftUI

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var newsExpanded: Bool = true
    @State private var schedule: [IPNScheduleModel] = []
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnNewsScreen,
        fallback: true
    ) private var newsEnabled
    @RemoteConfigProperty(
        key: AppConstants.RemoteConfigKeys.ipnScheduleScreen,
        fallback: true
    ) private var ipnScheduleEnabled

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                if ipnScheduleEnabled {
                    CustomLabel(text: Localization.upcomingEvents) {
                        router.navigate(to: .ipnSchedule)
                    }
                    UpcomingEventsView(
                        schedule: schedule,
                        maxEvents: EnvironmentConstants.homeMaxEvents
                    )
                    Divider()
                }
                if newsEnabled {
                    CustomLabel(text: Localization.latestNewsIPN) {
                        router.navigate(to: .news)
                    }
                    NewsView(
                        newsCount: EnvironmentConstants.homeNewsCount,
                        columnsCount: EnvironmentConstants.homeNewsColumns
                    )
                }
            }
            .padding(16)
        }
        .task {
            if ipnScheduleEnabled {
                schedule = await fetchIPNSchedule()
            }
        }
    }

    struct CustomLabel: View {
        let text: String
        let action: () -> Void

        var body: some View {
            HStack {
                Label {
                    Text(text)
                        .font(.headline)
                        .foregroundStyle(.primary)
                } icon: {
                    Image(systemName: "link")
                        .font(.headline)
                        .foregroundStyle(.saes)
                        .clipShape(.circle)
                }
                .onTapGesture(perform: action)
                Spacer()
            }
        }
    }
}
