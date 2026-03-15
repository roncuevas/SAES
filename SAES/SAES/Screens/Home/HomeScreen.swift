@preconcurrency import FirebaseRemoteConfig
import Foundation
import SwiftUI
import WidgetKit

@MainActor
struct HomeScreen: View, IPNScheduleFetcher {
    @EnvironmentObject private var router: AppRouter
    @ObservedObject private var scheduleStore = ScheduleStore.shared
    @ObservedObject private var scholarshipManager = ScholarshipManager.shared
    @ObservedObject private var announcementManager = AnnouncementManager.shared
    @ObservedObject private var calendarExporter = ScheduleCalendarExporter.shared
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
                MenuDonorBadge()
                    .frame(maxWidth: .infinity, alignment: .center)
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
                    } trailing: {
                        Button {
                            if calendarExporter.isAddedToCalendar {
                                calendarExporter.handleRemove()
                            } else {
                                calendarExporter.showSheet = true
                            }
                        } label: {
                            Image(systemName: calendarExporter.isAddedToCalendar
                                  ? "calendar.badge.minus"
                                  : "calendar.badge.plus")
                                .imageScale(.medium)
                                .foregroundStyle(.saes)
                        }
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
        .sheet(isPresented: $calendarExporter.showSheet) {
            CalendarExportSheet()
        }
        .task {
            await AnalyticsManager.shared.logScreen("home")
            if showTodaySchedule && !scheduleStore.hasData {
                loadScheduleFromCache()
            }
            calendarExporter.checkIfExported()
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
                if !schedule.isEmpty {
                    WidgetDataStore.shared.saveIPNEvents(schedule)
                    WidgetCenter.shared.reloadTimelines(ofKind: "IPNEventsWidget")
                }
            }
            await announcementsTask
            await scholarshipsTask
        }
    }

    private func loadScheduleFromCache() {
        let schoolCode = UserDefaults.schoolCode
        guard !schoolCode.isEmpty,
              let cache = OfflineCacheManager.shared.load(schoolCode),
              !cache.schedule.isEmpty else { return }
        let horario = ScheduleViewModel.buildHorarioSemanal(from: cache.schedule)
        scheduleStore.update(items: cache.schedule, horario: horario)
    }
}
