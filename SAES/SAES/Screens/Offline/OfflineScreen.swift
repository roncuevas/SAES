import SwiftUI
import Toast

@MainActor
struct OfflineScreen: View {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedTab = 0
    @State private var cache: OfflineCache?
    @State private var collapsedMaterias: Set<String> = []
    @State private var horarioSemanal: HorarioSemanal?
    @ObservedObject private var receiptManager = ScheduleReceiptManager.shared
    @StateObject private var calendarExporter = ScheduleCalendarExporter()
    @State private var showCalendarExportSheet = false
    @State private var selectedAlarmOffset: ScheduleCalendarExporter.AlarmOffset = .five

    private let dayOrder = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]

    var body: some View {
        VStack(spacing: 0) {
            if let cache {
                lastUpdatedBanner(cache.lastUpdated)

                Picker("", selection: $selectedTab) {
                    Text(Localization.offlineGrades).tag(0)
                    Text(Localization.offlineKardex).tag(1)
                    Text(Localization.offlineSchedule).tag(2)
                    Text(Localization.offlinePersonalData).tag(3)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                switch selectedTab {
                case 0: gradesTab(cache.grades)
                case 1: kardexTab(cache.kardex)
                case 2: scheduleTab(cache.schedule)
                case 3: personalDataTab(cache.personalData)
                default: EmptyView()
                }
            } else {
                NoContentView(
                    title: Localization.noOfflineData,
                    description: Localization.noContentDescription,
                    icon: Image(systemName: "wifi.slash")
                )
            }
        }
        .navigationTitle(Localization.offlineMode)
        .navigationBarTitleDisplayMode(.inline)
        .quickLookPreview($receiptManager.pdfURL)
        .onAppear {
            let loaded = OfflineCacheManager.shared.load(schoolCode)
            cache = loaded
            if let schedule = loaded?.schedule, !schedule.isEmpty {
                horarioSemanal = ScheduleViewModel.buildHorarioSemanal(from: schedule)
            }
            receiptManager.refreshCacheState()
            calendarExporter.checkIfExported()
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
    }

    // MARK: - Last Updated Banner

    private func lastUpdatedBanner(_ date: Date) -> some View {
        HStack {
            Image(systemName: "clock")
                .font(.caption)
            Text("\(Localization.lastUpdated): \(date.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
    }

    // MARK: - Grades Tab

    @ViewBuilder
    private func gradesTab(_ grades: [Grupo]) -> some View {
        if grades.isEmpty {
            noDataView
        } else {
            List {
                ForEach(grades) { grupo in
                    Section {
                        ForEach(grupo.materias) { materia in
                            GradesScreen.MateriaGradeRow(
                                materia: materia,
                                isExpanded: Binding(
                                    get: { !collapsedMaterias.contains(materia.id) },
                                    set: { newValue in
                                        if newValue {
                                            collapsedMaterias.remove(materia.id)
                                        } else {
                                            collapsedMaterias.insert(materia.id)
                                        }
                                    }
                                )
                            )
                        }
                    } header: {
                        Text(grupo.nombre)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - Kardex Tab

    @ViewBuilder
    private func kardexTab(_ kardexModel: KardexModel?) -> some View {
        if let kardexModel, let kardexList = kardexModel.kardex, !kardexList.isEmpty {
            List {
                ForEach(kardexList, id: \.semestre) { kardex in
                    if kardex.materias?.count ?? 0 > 0 {
                        Section {
                            ForEach(kardex.materias ?? [], id: \.clave) { materia in
                                KardexModelView.MateriaKardexRow(materia: materia)
                            }
                        } header: {
                            Text(kardex.semestre ?? "")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        } else {
            noDataView
        }
    }

    // MARK: - Schedule Tab

    @ViewBuilder
    private func scheduleTab(_ items: [ScheduleItem]) -> some View {
        if items.isEmpty || horarioSemanal == nil {
            noDataView
        } else {
            let horario = horarioSemanal!
            let allSubjects = items.map(\.materia)
            List {
                ForEach(dayOrder, id: \.self) { day in
                    if let materias = horario.horarioPorDia[day], !materias.isEmpty {
                        let sorted = materias.sorted {
                            RangoHorario.esMenorQue($0.horas.first, $1.horas.first)
                        }
                        Section {
                            ForEach(sorted, id: \.materia) { materia in
                                ScheduleListRowView(
                                    materia: materia,
                                    scheduleItem: items.first { $0.materia == materia.materia },
                                    color: SubjectColorProvider.color(for: materia.materia, in: allSubjects)
                                )
                            }
                        } header: {
                            Text(day)
                        }
                    }
                }

                scheduleActionsSection
            }
            .listStyle(.insetGrouped)
        }
    }

    private var scheduleActionsSection: some View {
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

            if receiptManager.hasCachedPDF {
                Button {
                    receiptManager.showCachedPDF()
                } label: {
                    Label(Localization.scheduleReceipt, systemImage: ScheduleReceiptManager.icon)
                }
            }
        }
    }

    // MARK: - Personal Data Tab

    @ViewBuilder
    private func personalDataTab(_ data: [String: String]) -> some View {
        if data.isEmpty {
            noDataView
        } else {
            List {
                PersonalDataListContent(data: data)
            }
            .listStyle(.insetGrouped)
        }
    }

    // MARK: - No Data

    private var noDataView: some View {
        NoContentView(
            title: Localization.noOfflineData,
            description: Localization.noContentDescription,
            icon: Image(systemName: "tray")
        )
        .frame(maxHeight: .infinity)
    }

    // MARK: - Calendar Handlers

    private func handleExport() {
        guard let cache, let horario = horarioSemanal else { return }
        let items = cache.schedule
        Task {
            do {
                let count = try await calendarExporter.exportSchedule(
                    items: items,
                    horarioSemanal: horario,
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
}
