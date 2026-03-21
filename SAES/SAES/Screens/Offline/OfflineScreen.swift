import SwiftUI

@MainActor
struct OfflineScreen: View {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedTab = 0
    @State private var cache: OfflineCache?
    @State private var collapsedMaterias: Set<String> = []
    @State private var horarioSemanal: HorarioSemanal?
    @ObservedObject private var receiptManager = ScheduleReceiptManager.shared
    @ObservedObject private var calendarExporter = ScheduleCalendarExporter.shared

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
        .task {
            await AnalyticsManager.shared.logScreen("offline")
        }
        .onAppear {
            let loaded = OfflineCacheManager.shared.load(schoolCode)
            cache = loaded
            if let schedule = loaded?.schedule, !schedule.isEmpty {
                let horario = ScheduleViewModel.buildHorarioSemanal(from: schedule)
                horarioSemanal = horario
                ScheduleStore.shared.update(items: schedule, horario: horario)
            }
            receiptManager.refreshCacheState()
            calendarExporter.checkIfExported()
        }
        .sheet(isPresented: $calendarExporter.showSheet) {
            CalendarExportSheet()
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
            ZStack(alignment: .bottomTrailing) {
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

                FloatingToggleButton(
                    systemImage: collapsedMaterias.isEmpty
                        ? "rectangle.compress.vertical"
                        : "rectangle.expand.vertical"
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if collapsedMaterias.isEmpty {
                            let allIds = grades.flatMap { $0.materias.map(\.id) }
                            collapsedMaterias = Set(allIds)
                        } else {
                            collapsedMaterias = []
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, 4)
            }
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
        if items.isEmpty {
            noDataView
        } else if let horario = horarioSemanal {
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
        } else {
            noDataView
        }
    }

    private var scheduleActionsSection: some View {
        Section {
            Button {
                calendarExporter.showSheet = true
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
}
