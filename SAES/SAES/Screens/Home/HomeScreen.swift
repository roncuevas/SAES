@preconcurrency import FirebaseRemoteConfig
import Foundation
import SwiftUI

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var scheduleStore = ScheduleStore.shared
    @ObservedObject private var scholarshipManager = ScholarshipManager.shared
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
                    Divider()
                }
                if scheduleStore.hasData,
                   let result = TodayScheduleHelper.todayClasses(from: scheduleStore) {
                    let title = result.isToday
                        ? Localization.todaysSchedule
                        : Localization.scheduleForDay(result.dayKey)
                    TodayScheduleSectionView(title: title, classes: result.classes) {
                        TabManager.shared.switchTo(.schedules)
                    }
                    Divider()
                }
                HomeSectionHeader(icon: "graduationcap", title: Localization.becas) {
                    router.navigateTo(.scholarships)
                } trailing: {
                    if let count = scholarshipManager.response?.data.nuevas, count > 0 {
                        Text(Localization.newScholarshipsCount(count))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.saes))
                    }
                }
                HomeScholarshipsView(
                    scholarships: Array(scholarshipManager.scholarships.prefix(EnvironmentConstants.homeScholarshipsCount))
                )
            }
            .padding(16)
        }
        .task {
            async let scholarshipsTask: Void = { try? await scholarshipManager.fetch() }()
            if ipnScheduleEnabled {
                async let scheduleTask = fetchIPNSchedule()
                schedule = await scheduleTask
            }
            await scholarshipsTask
        }
    }
}
