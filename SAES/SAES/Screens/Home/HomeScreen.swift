@preconcurrency import FirebaseRemoteConfig
import Foundation
import SwiftUI

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var scheduleStore = ScheduleStore.shared
    @State private var newsExpanded: Bool = true
    @State private var schedule: [IPNScheduleEvent] = []
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
                if scheduleStore.hasData {
                    let todayClasses = TodayScheduleHelper.todayClasses(from: scheduleStore)
                    if !todayClasses.isEmpty {
                        TodayScheduleSectionView(classes: todayClasses) {
                            // TODO: navegar al tab de horario
                        }
                        Divider()
                    }
                }
                if ipnScheduleEnabled {
                    SectionHeaderButton(text: Localization.upcomingEvents) {
                        router.navigateTo(.ipnSchedule)
                    }
                    UpcomingEventsView(
                        schedule: schedule,
                        maxEvents: EnvironmentConstants.homeMaxEvents
                    )
                    Divider()
                }
                if newsEnabled {
                    SectionHeaderButton(text: Localization.latestNewsIPN) {
                        router.navigateTo(.news)
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
}
