import Foundation
import Routing
import SwiftUI

struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: Router<NavigationRoutes>
    @State private var newsExpanded: Bool = true
    @State private var schedule: [IPNScheduleModel] = []

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                CustomLabel(text: Localization.upcomingEvents) {
                    router.navigate(to: .ipnSchedule)
                }
                UpcomingEventsView(
                    schedule: schedule,
                    maxEvents: EnvironmentConstants.homeMaxEvents
                )
                Divider()
                CustomLabel(text: Localization.latestNewsIPN) {
                    router.navigate(to: .news)
                }
                NewsView(
                    newsCount: EnvironmentConstants.homeNewsCount,
                    columnsCount: EnvironmentConstants.homeNewsColumns
                )
            }
            .padding(16)
        }
        .task {
            schedule = await fetchIPNSchedule()
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
