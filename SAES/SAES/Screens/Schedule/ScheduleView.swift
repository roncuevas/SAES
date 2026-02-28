import EventKit
import EventKitUI
import SwiftUI
import Toast

@MainActor
struct ScheduleView: View {
    @State private var store = EKEventStore()
    @State private var showEventEditViewController: Bool = false
    @State private var editingEvent: EKEvent?
    @State private var showEventAlert: Bool = false
    @State private var showEventTitle: String = ""
    @State private var showEventMessage: String = ""
    @StateObject private var viewModel: ScheduleViewModel = ScheduleViewModel()
    @StateObject private var calendarExporter = ScheduleCalendarExporter()
    @ObservedObject private var receiptManager = ScheduleReceiptManager.shared
    @State private var showCalendarExportSheet = false
    @State private var selectedAlarmOffset: ScheduleCalendarExporter.AlarmOffset = .five

    var body: some View {
        content
            .appErrorOverlay(isDataLoaded: !viewModel.schedule.isEmpty)
            .task {
                receiptManager.refreshCacheState()
                calendarExporter.checkIfExported()
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
            .sheet(isPresented: $showCalendarExportSheet) {
                CalendarExportSheet(
                    selectedAlarmOffset: $selectedAlarmOffset,
                    isExporting: calendarExporter.isExporting,
                    isAddedToCalendar: calendarExporter.isAddedToCalendar,
                    onExport: { handleExport() },
                    onRemove: { handleRemove() },
                    onCancel: { showCalendarExportSheet = false }
                )
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

    private var viewModeButton: some View {
        FloatingToggleButton(
            systemImage: viewModel.viewMode == .list ? "square.grid.2x2" : "list.bullet"
        ) {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.viewMode = viewModel.viewMode == .list ? .grid : .list
            }
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
                    Button {
                        showCalendarExportSheet = true
                    } label: {
                        Label(
                            calendarExporter.isAddedToCalendar
                                ? Localization.removeFromCalendar
                                : Localization.addToCalendar,
                            systemImage: calendarExporter.isAddedToCalendar
                                ? "calendar.badge.minus"
                                : "calendar.badge.plus"
                        )
                    }
                    Button {
                        Task { await receiptManager.getPDFData() }
                    } label: {
                        Label(Localization.scheduleReceipt, systemImage: ScheduleReceiptManager.icon)
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

    private func handleExport() {
        Task {
            do {
                let count = try await calendarExporter.exportSchedule(
                    items: viewModel.schedule,
                    horarioSemanal: viewModel.horarioSemanal,
                    alarmOffset: selectedAlarmOffset
                )
                showCalendarExportSheet = false
                ToastManager.shared.toastToPresent = Toast(
                    icon: Image(systemName: "checkmark.circle.fill"),
                    color: .green,
                    message: Localization.eventsAddedToCalendar(count)
                )
            } catch ScheduleCalendarExporter.ExportError.calendarAccessDenied {
                showCalendarExportSheet = false
                showEventTitle = Localization.errorAccessingCalendar
                showEventMessage = Localization.calendarPermissionDenied
                showEventAlert = true
            } catch {
                showCalendarExportSheet = false
                ToastManager.shared.toastToPresent = Toast(
                    icon: Image(systemName: "exclamationmark.triangle.fill"),
                    color: .red,
                    message: Localization.errorSavingEvent
                )
            }
        }
    }

    private func handleRemove() {
        do {
            try calendarExporter.removeSchedule()
            showCalendarExportSheet = false
            ToastManager.shared.toastToPresent = Toast(
                icon: Image(systemName: "checkmark.circle.fill"),
                color: .green,
                message: Localization.scheduleRemovedFromCalendar
            )
        } catch {
            showCalendarExportSheet = false
            ToastManager.shared.toastToPresent = Toast(
                icon: Image(systemName: "exclamationmark.triangle.fill"),
                color: .red,
                message: Localization.errorSavingEvent
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
