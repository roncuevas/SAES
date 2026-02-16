import EventKit
import EventKitUI
import SwiftUI

@MainActor
struct ScheduleView: View {
    @State private var store = EKEventStore()
    @State private var showEventEditViewController: Bool = false
    @State private var editingEvent: EKEvent?
    @State private var showEventAlert: Bool = false
    @State private var showEventTitle: String = ""
    @State private var showEventMessage: String = ""
    @StateObject private var viewModel: ScheduleViewModel = ScheduleViewModel()
    @ObservedObject private var receiptManager = ScheduleReceiptManager.shared

    var body: some View {
        content
            .appErrorOverlay(isDataLoaded: !viewModel.schedule.isEmpty)
            .task {
                guard viewModel.schedule.isEmpty else { return }
                await viewModel.getSchedule()
            }
            .alert(
                showEventTitle, isPresented: $showEventAlert,
                actions: {
                    Button(Localization.okey) {
                        showEventAlert = false
                    }
                },
                message: {
                    Text(showEventMessage)
                }
            )
            .sheet(isPresented: $showEventEditViewController) {
                AddEvent(event: $editingEvent)
            }
            .refreshable {
                await viewModel.getSchedule()
            }
    }

    @ViewBuilder
    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForSchedule,
            retryAction: { Task { await viewModel.getSchedule() } },
            secondButtonTitle: receiptManager.hasCachedPDF ? Localization.scheduleReceipt : nil,
            secondButtonIcon: receiptManager.hasCachedPDF ? ScheduleReceiptManager.icon : nil,
            secondaryAction: receiptManager.hasCachedPDF ? { Task { await receiptManager.getPDFData() } } : nil
        ) {
            List {
                ForEach(EventManager.weekDays, id: \.self) { dia in
                    if let materias = viewModel.horarioSemanal.horarioPorDia[dia] {
                        Section(header: Text(dia)) {
                            getViews(dia: dia, materias: materias)
                        }
                    }
                }
                if !viewModel.schedule.isEmpty {
                    Section {
                        Button(Localization.scheduleReceipt) {
                            Task { await receiptManager.getPDFData() }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func getViews(
        dia: String,
        materias: [MateriaConHoras]
    ) -> some View {
        let materiasSortedByHour = materias.sorted(by: {
            RangoHorario.esMenorQue($0.horas.first, $1.horas.first)
        })
        ForEach(materiasSortedByHour, id: \.materia) { materia in
            HStack {
                VStack(alignment: .leading) {
                    Text(materia.materia).font(.headline)
                    ForEach(materia.horas, id: \.inicio) { rango in
                        Text(rango.inicio + " - " + rango.fin)
                            .font(.subheadline)
                    }
                }
                Spacer()
                // MARK: Add to calendar
                #if DEBUG
                Button {
                    editingEvent = EventManager.getWeeklyEvent(
                        eventStore: EventManager.shared.eventStore,
                        eventTitle: Localization.subject.colon.space + materia.materia,
                        startingOnDayOfWeek: dia,
                        startTime: materia.horas.first?.inicio,
                        endTime: materia.horas.last?.fin,
                        until: Date.now.addingTimeInterval(1_209_600)
                    )
                } label: {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundStyle(.saes)
                        .font(.system(size: 28, weight: .light))
                }
                .padding(.trailing, 8)
                #endif
            }
        }
    }

    private func saveEvent(event: EKEvent) {
        EventManager.shared.eventStore.requestAccess(to: .event) { (granted, error) in
            if granted && error == nil {
                do {
                    try EventManager.shared.eventStore.save(
                        event, span: .thisEvent)
                    showEventTitle = Localization.eventSavedCorrectly
                    showEventMessage = String(describing: event.title).space + Localization.fromText.space +
                    String(describing: event.startDate).space + Localization.toText.space + String(describing: event.endDate)
                } catch let error as NSError {
                    showEventTitle = Localization.errorSavingEvent.space + error.localizedDescription
                }
            } else {
                showEventTitle = Localization.errorAccessingCalendar.space + String(describing: error)
            }
            showEventAlert = true
        }
    }
}
