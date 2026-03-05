import SwiftUI

@MainActor
struct OfflineScreen: View {
    @AppStorage("schoolCode") private var schoolCode: String = ""
    @State private var selectedTab = 0
    @State private var cache: OfflineCache?
    @State private var collapsedMaterias: Set<String> = []

    private let dayOrder = ["Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]

    var body: some View {
        VStack(spacing: 0) {
            if let cache {
                lastUpdatedBanner(cache.lastUpdated)

                Picker("", selection: $selectedTab) {
                    Text(Localization.offlineGrades).tag(0)
                    Text(Localization.offlineKardex).tag(1)
                    Text(Localization.offlineSchedule).tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                switch selectedTab {
                case 0: gradesTab(cache.grades)
                case 1: kardexTab(cache.kardex)
                case 2: scheduleTab(cache.schedule)
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
        .onAppear {
            cache = OfflineCacheManager.shared.load(schoolCode)
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
