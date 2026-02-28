@preconcurrency import FirebaseRemoteConfig
import Foundation
import SwiftUI

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @Binding var selectedTab: LoggedTabs
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var scheduleStore = ScheduleStore.shared
    @State private var newsGrid: Bool = true
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
                if scheduleStore.hasData,
                   let result = TodayScheduleHelper.todayClasses(from: scheduleStore) {
                    let title = result.isToday
                        ? Localization.todaysSchedule
                        : Localization.scheduleForDay(result.dayKey)
                    TodayScheduleSectionView(title: title, classes: result.classes) {
                        selectedTab = .schedules
                    }
                    Divider()
                }
                if ipnScheduleEnabled {
                    HomeSectionHeader(icon: "calendar", title: Localization.upcomingEvents) {
                        router.navigateTo(.ipnSchedule)
                    }
                    UpcomingEventsView(
                        schedule: schedule,
                        maxEvents: EnvironmentConstants.homeMaxEvents
                    )
                    Divider()
                }
                if newsEnabled {
                    HomeSectionHeader(icon: "newspaper", title: Localization.ipnNews) {
                        router.navigateTo(.news)
                    } trailing: {
                        Button {
                            withAnimation { newsGrid.toggle() }
                        } label: {
                            Image(systemName: newsGrid ? "square.grid.2x2" : "rectangle.grid.1x2")
                                .imageScale(.medium)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.saes)
                        }
                    }
                    HomeNewsView(
                        newsCount: EnvironmentConstants.homeNewsCount,
                        isGrid: newsGrid
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
