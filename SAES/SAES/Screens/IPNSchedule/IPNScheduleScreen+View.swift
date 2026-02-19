import SwiftUI

extension IPNScheduleScreen: View, IPNScheduleFetcher {
    var body: some View {
        content
            .navigationTitle(Localization.ipnSchedule)
            .navigationBarTitleDisplayMode(.inline)
            .quickLookPreview($pdfURL)
            .task {
                await AnalyticsManager.shared.logScreen("ipnSchedule")
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

    // MARK: - Subscription

    private var subscriptionSection: some View {
        Section {
            HStack(spacing: 12) {
                Button {
                    guard let url = URL(string: webcalYes) else { return }
                    openURL(url)
                } label: {
                    Label(Localization.inPersonMode, systemImage: "calendar.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.saes, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    guard let url = URL(string: webcalNo) else { return }
                    openURL(url)
                } label: {
                    Label(Localization.remoteMode, systemImage: "calendar.badge.plus")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.saes, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.horizontal)
            .padding(.vertical, 8)
        } header: {
            Text(Localization.subscribeHeader)
        } footer: {
            Text(Localization.subscribeFooter)
        }
    }

    // MARK: - PDF

    private var pdfSection: some View {
        Section {
            Button {
                pdfURL = Bundle.main.url(forResource: "escolarizada", withExtension: "pdf")
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.saes)
                    Text(Localization.inPersonMode)
                    Spacer()
                    Image(systemName: "arrow.down.to.line")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .tint(.primary)

            Button {
                pdfURL = Bundle.main.url(forResource: "noescolarizado", withExtension: "pdf")
            } label: {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .foregroundStyle(.saes)
                    Text(Localization.remoteMode)
                    Spacer()
                    Image(systemName: "arrow.down.to.line")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .tint(.primary)
        } header: {
            Text(Localization.pdfHeader)
        } footer: {
            Text(Localization.pdfFooter)
        }
    }

    // MARK: - Upcoming Events

    @ViewBuilder
    private var upcomingEventsSection: some View {
        Section(Localization.upcomingEvents) {
            if allEvents.isEmpty {
                Text(Localization.noUpcomingEvents)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(allEvents.prefix(8), id: \.self) { event in
                    EventCardView(event: event)
                }
            }
        }
    }

    private var allEvents: [IPNScheduleEvent] {
        schedule.flatMap { $0.events }.validEvents
    }
}
