@preconcurrency import FirebaseRemoteConfig
import Foundation
import SwiftUI

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var scheduleStore = ScheduleStore.shared
    @ObservedObject private var scholarshipManager = ScholarshipManager.shared
    @ObservedObject private var announcementManager = AnnouncementManager.shared
    @State private var newsGrid: Bool = true
    @State private var schedule: [IPNScheduleEvent] = []
    @AppStorage(AppConstants.UserDefaultsKeys.showUpcomingEvents) private var showUpcomingEvents = true
    @AppStorage(AppConstants.UserDefaultsKeys.showNews) private var showNews = true
    @AppStorage(AppConstants.UserDefaultsKeys.showTodaySchedule) private var showTodaySchedule = true
    @AppStorage(AppConstants.UserDefaultsKeys.showScholarships) private var showScholarships = true
    @AppStorage(AppConstants.UserDefaultsKeys.showAnnouncements) private var showAnnouncements = true
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
                if ipnScheduleEnabled && showUpcomingEvents {
                    HomeSectionHeader(icon: "calendar", title: Localization.upcomingEvents) {
                        router.navigateTo(.ipnSchedule)
                    }
                    UpcomingEventsView(
                        schedule: schedule,
                        maxEvents: EnvironmentConstants.homeMaxEvents
                    )
                    Divider()
                }
                if newsEnabled && showNews {
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
                if showTodaySchedule,
                   scheduleStore.hasData,
                   let result = TodayScheduleHelper.todayClasses(from: scheduleStore) {
                    let title = result.isToday
                        ? Localization.todaysSchedule
                        : Localization.scheduleForDay(result.dayKey)
                    TodayScheduleSectionView(title: title, classes: result.classes) {
                        TabManager.shared.switchTo(.schedules)
                    }
                    Divider()
                }
                if showAnnouncements {
                    HomeSectionHeader(icon: "megaphone", title: Localization.announcements) {
                        router.navigateTo(.announcements)
                    } trailing: {
                        let urgentCount = announcementManager.announcements.filter { $0.tipo == .urgente }.count
                        if urgentCount > 0 {
                            Text(Localization.urgentAnnouncementsCount(urgentCount))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(.red))
                        }
                    }
                    HomeAnnouncementsView(
                        announcements: Array(
                            announcementManager.announcements.prefix(EnvironmentConstants.homeAnnouncementsCount)
                        )
                    )
                    Divider()
                }
                if showScholarships {
                    HomeSectionHeader(icon: "graduationcap", title: Localization.becas) {
                        router.navigateTo(.scholarships)
                    }
                    HomeScholarshipsView(
                        scholarships: Array(scholarshipManager.scholarships.prefix(EnvironmentConstants.homeScholarshipsCount))
                    )
                }
            }
            .padding(16)
        }
        .task {
            let shouldFetchAnnouncements = showAnnouncements
            let shouldFetchScholarships = showScholarships
            async let announcementsTask: Void = {
                guard shouldFetchAnnouncements else { return }
                try? await announcementManager.fetch()
            }()
            async let scholarshipsTask: Void = {
                guard shouldFetchScholarships else { return }
                try? await scholarshipManager.fetch()
            }()
            if ipnScheduleEnabled && showUpcomingEvents {
                async let scheduleTask = fetchIPNSchedule()
                schedule = await scheduleTask
            }
            await announcementsTask
            await scholarshipsTask
        }
    }
}
