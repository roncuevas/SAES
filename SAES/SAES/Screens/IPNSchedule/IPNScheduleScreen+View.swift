import Foundation
import SwiftUI

extension IPNScheduleScreen: View {
    var body: some View {
        content
            .quickLookPreview($pdfURL)
            .task {
                do {
                    self.schedule = try await NetworkManager.shared.sendRequest(url: scheduleURL,
                                                                                type: IPNScheduleResponse.self)
                } catch {
                    print(error)
                }
            }
    }

    @ViewBuilder
    var content: some View {
        List {
            subscriptionSection
            pdfSection
            if !schedule.isEmpty {
                Section(Localization.upcomingEvents) {
                    ForEach(schedule, id: \.self) { element in
                        eventsSectionView(element)
                    }
                }
            } else {
                SearchingView(title: Localization.searchingIPNSchedule)
            }
        }
    }

    @ViewBuilder
    private func eventsSectionView(_ element: IPNScheduleModel) -> some View {
        let validEvents = element.validEvents
        if !validEvents.isEmpty {
            ForEach(validEvents, id: \.self) { event in
                VStack(alignment: .leading) {
                    Text(event.type.eventEmoji + event.name)
                        .fontWeight(.semibold)
                    Text(event.dateRange.toStringInterval)
                        .multilineTextAlignment(.leading)
                }
            }
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
