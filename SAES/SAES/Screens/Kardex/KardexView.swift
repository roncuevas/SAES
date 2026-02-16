import SwiftUI
@preconcurrency import Inject

@MainActor
struct KardexModelView: View {
    @ObserveInjection var forceRedraw
    @StateObject private var viewModel = KardexViewModel()
    @State private var searchText: String = ""
    @State private var studentID: String?

    var body: some View {
        NavigationView {
            content
                .appErrorOverlay(isDataLoaded: viewModel.kardexModel != nil)
                .menuToolbar(items: MenuConfiguration.logged.items)
                .logoutToolbar()
                .navigationBarTitle(
                    title: Localization.kardex,
                    titleDisplayMode: .inline,
                    background: .visible,
                    backButtonHidden: true
                )
        }
        .navigationViewStyle(.stack)
        .searchable(
            text: $searchText,
            placement: .toolbar,
            prompt: Localization.prompt
        )
        .task {
            guard viewModel.kardexModel == nil else { return }
            await viewModel.getKardex()
        }
        .task {
            let user = await UserSessionManager.shared.currentUser()
            studentID = user?.studentID
        }
        .refreshable {
            viewModel.kardexModel = nil
            await viewModel.getKardex()
        }
    }

    @ViewBuilder
    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForKardex,
            retryAction: { Task { await viewModel.getKardex() } }
        ) {
            if let kardexModel = viewModel.kardexModel {
                List {
                    studentInfoSection(kardexModel)
                    statsSection(kardexModel)

                    if let kardexList = kardexModel.kardex {
                        ForEach(filteredKardexList(kardexList), id: \.semestre) { kardex in
                            if kardex.materias?.count ?? 0 > 0 {
                                Section {
                                    ForEach(kardex.materias ?? [], id: \.clave) { materia in
                                        MateriaKardexRow(materia: materia, forceExpanded: !searchText.isEmpty)
                                    }
                                } header: {
                                    semesterHeader(kardex)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollDismissesKeyboard(.interactively)
            }
        }
    }

    // MARK: - Student Info Section

    private func studentInfoSection(_ model: KardexModel) -> some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                infoRow(label: Localization.studentID, value: studentID)
                infoRow(label: Localization.degree, value: model.carrera)
                infoRow(label: Localization.plan, value: model.plan)
            }
        }
    }

    private func infoRow(label: String, value: String?) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "N/A")
                .font(.subheadline)
        }
    }

    // MARK: - Stats Section

    private func statsSection(_ model: KardexModel) -> some View {
        Section {
            HStack(spacing: 12) {
                statCard(value: "\(totalSubjects(model))", label: Localization.subjects)
                statCard(value: model.promedio ?? "N/A", label: Localization.gpa)
                statCard(value: "\(approvedSubjects(model))", label: Localization.approved)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }

    private func statCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundStyle(.saes)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.saes, lineWidth: 1)
        )
    }

    // MARK: - Semester Header

    private func semesterHeader(_ kardex: Kardex) -> some View {
        HStack {
            Text(kardex.semestre ?? "N/A")
            Spacer()
            Text("\(Localization.avg): \(semesterAverage(kardex))")
                .font(.caption)
                .foregroundStyle(.saes)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.saes.opacity(0.1))
                .clipShape(Capsule())
        }
    }

    // MARK: - Helpers

    private func semesterAverage(_ semester: Kardex) -> String {
        guard let materias = semester.materias else { return "N/A" }
        let grades = materias.compactMap { Double($0.calificacion ?? "") }
        guard !grades.isEmpty else { return "N/A" }
        let avg = grades.reduce(0, +) / Double(grades.count)
        return String(format: "%.1f", avg)
    }

    private func totalSubjects(_ model: KardexModel) -> Int {
        model.kardex?.reduce(0) { $0 + ($1.materias?.count ?? 0) } ?? 0
    }

    private func approvedSubjects(_ model: KardexModel) -> Int {
        model.kardex?.flatMap { $0.materias ?? [] }
            .filter { Double($0.calificacion ?? "") ?? 0 >= 6.0 }
            .count ?? 0
    }

    private func filteredKardexList(_ kardexList: [Kardex]) -> [Kardex] {
        if searchText.isEmpty {
            return kardexList
        } else {
            return kardexList.map { kardex in
                let filteredMaterias = kardex.materias?.filter { materia in
                    materia.materia?.localizedStandardContains(searchText) ?? false
                }
                return Kardex(semestre: kardex.semestre, materias: filteredMaterias)
            }
        }
    }

    // MARK: - Materia Row

    struct MateriaKardexRow: View {
        let materia: MateriaKardex
        var forceExpanded: Bool = false
        @State private var isExpanded = false

        private var expanded: Bool { isExpanded || forceExpanded }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(expanded ? 90 : 0))

                        Text(materia.materia ?? "N/A")
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        Text(materia.calificacion ?? "N/A")
                            .font(.body)
                            .bold()
                            .foregroundStyle(.saes)
                    }
                }
                .buttonStyle(.plain)

                if expanded {
                    VStack(spacing: 8) {
                        detailRow(label: Localization.key, value: materia.clave ?? "N/A")
                        detailRow(label: Localization.period, value: materia.periodo ?? "N/A")
                        detailRow(label: Localization.evaluationMethod, value: materia.formaEval ?? "N/A")
                        detailRow(label: Localization.date, value: materia.fecha ?? "N/A")
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 24)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }

        private func detailRow(label: String, value: String) -> some View {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}
