import Foundation
import SwiftUI

extension IPNScheduleScreen: View, IPNScheduleFetcher {
    var body: some View {
        content
            .navigationTitle(Localization.ipnSchedule)
            .quickLookPreview($pdfURL)
            .task {
                AnalyticsManager.shared.logScreen("ipnSchedule")
                schedule = await fetchIPNSchedule()
            }
    }

    @ViewBuilder
    var content: some View {
        List {
            subscriptionSection
            pdfSection
            upcomingEventsSection
        }
    }

    @ViewBuilder
    private var upcomingEventsSection: some View {
        Section(Localization.upcomingEvents) {
            UpcomingEventsView(schedule: schedule, maxEvents: 8)
        }
    }

    private var subscriptionSection: some View {
        Section {
            Button {
                guard let url = URL(string: webcalYes) else { return }
                openURL(url)
            } label: {
                Label(Localization.inPersonMode, systemImage: "calendar.badge.plus")
            }
            Button {
                guard let url = URL(string: webcalNo) else { return }
                openURL(url)
            } label: {
                Label(Localization.remoteMode, systemImage: "calendar.badge.plus")
            }
        } header: {
            Text(Localization.subscribeHeader)
        } footer: {
            Text(Localization.subscribeFooter)
        }
    }

    private var pdfSection: some View {
        Section {
            Button {
                pdfURL = Bundle.main.url(forResource: "escolarizada", withExtension: "pdf")
            } label: {
                Label(Localization.inPersonMode, systemImage: "text.document.fill")
            }

            Button {
                pdfURL = Bundle.main.url(forResource: "noescolarizado", withExtension: "pdf")
            } label: {
                Label(Localization.remoteMode, systemImage: "text.document.fill")
            }

        } header: {
            Text(Localization.pdfHeader)
        } footer: {
            Text(Localization.pdfFooter)
        }
    }
}
