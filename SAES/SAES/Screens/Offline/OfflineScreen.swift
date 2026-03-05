import SwiftUI
import Toast

@MainActor
struct OfflineScreen: View {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedTab = 0
    @State private var cache: OfflineCache?
    @State private var collapsedMaterias: Set<String> = []
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
            cache = OfflineCacheManager.shared.load(schoolCode)
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
        if items.isEmpty {
            noDataView
        } else {
            let horario = ScheduleViewModel.buildHorarioSemanal(from: items)
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

                scheduleActionsSection(items: items, horario: horario)
            }
            .listStyle(.insetGrouped)
        }
    }

    private func scheduleActionsSection(items: [ScheduleItem], horario: HorarioSemanal) -> some View {
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
                if let name = data["name"], !name.isEmpty {
                    Section {
                        VStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white)
                                .frame(width: 88, height: 88)
                                .background(Color(.systemGray4))
                                .clipShape(.circle)

                            Text(name)
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)

                            if let studentID = data["studentID"], !studentID.isEmpty {
                                Text("\(Localization.studentID): \(studentID)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            if let campus = data["campus"], !campus.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "building.columns.fill")
                                    Text(campus)
                                }
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.saes)
                                .clipShape(.capsule)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }

                personalDataSection(icon: "person.text.rectangle", title: Localization.generalData, data: data, fields: [
                    (Localization.curp, "curp"),
                    (Localization.rfc, "rfc"),
                    (Localization.gender, "gender"),
                    (Localization.militaryID, "militaryID"),
                    (Localization.passport, "passport"),
                    (Localization.employed, "employed")
                ])

                personalDataSection(icon: "gift", title: Localization.birth, data: data, fields: [
                    (Localization.nationality, "nationality"),
                    (Localization.birthDay, "birthDay"),
                    (Localization.birthPlace, "birthPlace")
                ])

                personalDataSection(icon: "mappin.circle.fill", title: Localization.address, data: data, fields: [
                    (Localization.street, "street"),
                    (Localization.extNumber, "extNumber"),
                    (Localization.intNumber, "intNumber"),
                    (Localization.neighborhood, "neighborhood"),
                    (Localization.zipCode, "zipCode"),
                    (Localization.state, "state"),
                    (Localization.municipality, "municipality")
                ])

                personalDataSection(icon: "phone.fill", title: Localization.contact, data: data, fields: [
                    (Localization.email, "email"),
                    (Localization.mobile, "mobile"),
                    (Localization.phone, "phone"),
                    (Localization.officePhone, "officePhone")
                ])

                personalDataSection(icon: "graduationcap.fill", title: Localization.educationLevel, data: data, fields: [
                    (Localization.previousSchool, "previousSchool"),
                    (Localization.stateOfPreviousSchool, "stateOfPreviousSchool"),
                    (Localization.gpaMiddleSchool, "gpaMiddleSchool"),
                    (Localization.gpaHighSchool, "gpaHighSchool")
                ])

                personalDataSection(icon: "person.2.fill", title: Localization.parent, data: data, fields: [
                    (Localization.guardianName, "guardianName"),
                    (Localization.guardianRFC, "guardianRFC"),
                    (Localization.fathersName, "fathersName"),
                    (Localization.mothersName, "mothersName")
                ])
            }
            .listStyle(.insetGrouped)
        }
    }

    private func personalDataSection(icon: String, title: String, data: [String: String], fields: [(String, String)]) -> some View {
        let visible = fields.filter { _, key in
            guard let value = data[key] else { return false }
            return !value.replacingOccurrences(of: " ", with: "").isEmpty
        }
        return Section {
            ForEach(Array(visible.enumerated()), id: \.element.0) { _, field in
                CSTextSelectableView(header: field.0, description: data[field.1])
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
        } header: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .foregroundStyle(.saes)
            .font(.headline)
        }
        .textCase(nil)
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
        guard let cache else { return }
        let items = cache.schedule
        let horario = ScheduleViewModel.buildHorarioSemanal(from: items)
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
