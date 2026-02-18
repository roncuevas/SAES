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
                receiptManager.refreshCacheState()
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
            scheduleContent
        }
    }

    @ViewBuilder
    private var scheduleContent: some View {
        ZStack(alignment: .bottomTrailing) {
            switch viewModel.viewMode {
            case .list:
                listContent
            case .grid:
                ScheduleGridView(viewModel: viewModel)
            }

            viewModeButton
                .padding(16)
                .padding(.bottom, 4)
        }
    }

    @Environment(\.colorScheme) private var colorScheme

    private var viewModeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.viewMode = viewModel.viewMode == .list ? .grid : .list
            }
        } label: {
            Image(systemName: viewModel.viewMode == .list
                  ? "square.grid.2x2"
                  : "list.bullet")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(colorScheme == .dark ? .white : .saes)
                .padding(14)
                .background(
                    colorScheme == .dark ? Color.white.opacity(0.2) : Color(.systemBackground),
                    in: .circle
                )
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
        }
    }

    private var listContent: some View {
        List {
            ForEach(EventManager.weekDays, id: \.self) { dia in
                if let materias = viewModel.horarioSemanal.horarioPorDia[dia] {
                    Section {
                        getViews(dia: dia, materias: materias)
                    } header: {
                        Text(dia)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.saes)
                            .textCase(nil)
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

    @ViewBuilder
    private func getViews(
        dia: String,
        materias: [MateriaConHoras]
    ) -> some View {
        let materiasSortedByHour = materias.sorted(by: {
            RangoHorario.esMenorQue($0.horas.first, $1.horas.first)
        })
        ForEach(materiasSortedByHour, id: \.materia) { materia in
            ScheduleListRowView(
                materia: materia,
                scheduleItem: viewModel.scheduleItem(for: materia.materia),
                color: viewModel.color(for: materia.materia)
            )
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
