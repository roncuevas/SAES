import SwiftUI
import CustomKit

extension GradesScreen: View {
    var body: some View {
        content
            .appErrorOverlay(isDataLoaded: !viewModel.grades.isEmpty)
            .task {
                guard viewModel.grades.isEmpty else { return }
                await viewModel.getGrades()
            }
            .refreshable {
                await viewModel.getGrades()
            }
            .saesLoadingScreen(isLoading: $isLoadingScreen)
    }

    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForGrades,
            retryAction: { Task { await viewModel.getGrades() } }
        ) {
            if !viewModel.evaluateTeacher {
                loadedContent
            } else if teacherEvaluationEnabled {
                NoContentView(
                    title: Localization.needEvaluateTeachers,
                    description: Localization.youCanEvaluate,
                    firstButtonTitle: Localization.evaluateAutomatically,
                    icon: Image(systemName: "person.fill.checkmark.and.xmark"),
                    action: { isPresentingAlert.toggle() })
                .alert(
                    Localization.evaluateAutomatically,
                    isPresented: $isPresentingAlert) {
                        Button(Localization.evaluate) {
                            Task {
                                isLoadingScreen = true
                                await viewModel.evaluateTeachers()
                                await viewModel.getGrades()
                                isLoadingScreen = false
                            }
                        }
                        Button(Localization.cancel) {
                            isPresentingAlert.toggle()
                        }
                    } message: {
                        Text(Localization.thisWillRateTeachers)
                    }
            } else {
                NoContentView(
                    title: Localization.needEvaluateTeachers,
                    description: Localization.evaluateTeachersManually,
                    icon: Image(systemName: "person.fill.checkmark.and.xmark")
                )
            }
        }
    }

    private var hasNumericFinalGrades: Bool {
        viewModel.grades
            .flatMap { $0.materias }
            .contains { Double($0.calificaciones.final) != nil }
    }

    private var loadedContent: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if hasNumericFinalGrades {
                    statsSection
                }

                ForEach(viewModel.grades) { grupo in
                    Section {
                        ForEach(grupo.materias) { materia in
                            MateriaGradeRow(
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
                        groupHeader(grupo)
                    }
                }
            }
            .listStyle(.insetGrouped)

            collapseExpandButton
                .padding(16)
                .padding(.bottom, 4)
        }
        .navigationTitle(Localization.grades)
        .navigationBarBackButtonHidden()
        .webViewToolbar()
        .logoutToolbar()
    }

    private var allExpanded: Bool {
        collapsedMaterias.isEmpty
    }

    private var collapseExpandButton: some View {
        FloatingToggleButton(
            systemImage: allExpanded ? "chevron.up.2" : "chevron.down.2"
        ) {
            withAnimation(.easeInOut(duration: 0.2)) {
                if allExpanded {
                    let allIds = viewModel.grades.flatMap { $0.materias.map(\.id) }
                    collapsedMaterias = Set(allIds)
                } else {
                    collapsedMaterias = []
                }
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        Section {
            HStack(spacing: 12) {
                statCard(value: "\(totalSubjects)", label: Localization.subjects)
                statCard(value: generalAverage ?? "N/A", label: Localization.generalAverage)
                statCard(value: "\(approvedSubjects)", label: Localization.approved)
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

    // MARK: - Group Header

    private func groupHeader(_ grupo: Grupo) -> some View {
        HStack {
            Text("\(Localization.group) \(grupo.nombre)")
            Spacer()
            if let avg = groupAverage(grupo) {
                Text("\(Localization.avg): \(avg)")
                    .font(.caption)
                    .foregroundStyle(.saes)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.saes.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Helpers

    private var generalAverage: String? {
        let finalGrades = viewModel.grades
            .flatMap { $0.materias }
            .compactMap { Double($0.calificaciones.final) }
        guard !finalGrades.isEmpty else { return nil }
        let avg = finalGrades.reduce(0, +) / Double(finalGrades.count)
        return String(format: "%.1f", avg)
    }

    private func groupAverage(_ grupo: Grupo) -> String? {
        let grades = grupo.materias.compactMap { Double($0.calificaciones.final) }
        guard !grades.isEmpty else { return nil }
        let avg = grades.reduce(0, +) / Double(grades.count)
        return String(format: "%.1f", avg)
    }

    private var totalSubjects: Int {
        viewModel.grades.reduce(0) { $0 + $1.materias.count }
    }

    private var approvedSubjects: Int {
        viewModel.grades
            .flatMap { $0.materias }
            .filter { Double($0.calificaciones.final) ?? 0 >= 6.0 }
            .count
    }

    // MARK: - Materia Row

    struct MateriaGradeRow: View {
        private let chevronWidth: CGFloat = 10
        let materia: Materia
        @Binding var isExpanded: Bool

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
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                            .frame(width: chevronWidth)

                        Text(materia.nombre)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if hasFinalGrade {
                            Text(finalGradeDisplay)
                                .font(.body)
                                .bold()
                                .foregroundStyle(finalGradeColor)
                        }
                    }
                }
                .buttonStyle(.plain)

                if isExpanded {
                    VStack(spacing: 8) {
                        gradeRow(label: Localization.firstPartial, value: materia.calificaciones.primerParcial)
                        gradeRow(label: Localization.secondPartial, value: materia.calificaciones.segundoParcial)
                        gradeRow(label: Localization.thirdPartial, value: materia.calificaciones.tercerParcial)
                        gradeRow(label: Localization.extraordinary, value: materia.calificaciones.ext)
                        gradeRow(label: Localization.finalGrade, value: materia.calificaciones.final)
                    }
                    .padding(.top, 10)
                    .padding(.leading, chevronWidth + 8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }

        private var hasFinalGrade: Bool {
            !materia.calificaciones.final.trimmingCharacters(in: .whitespaces).isEmpty
        }

        private var finalGradeDisplay: String {
            materia.calificaciones.final.trimmingCharacters(in: .whitespaces)
        }

        private var finalGradeColor: Color {
            let trimmed = materia.calificaciones.final.trimmingCharacters(in: .whitespaces)
            guard let numericValue = Double(trimmed) else { return .secondary }
            return numericValue >= 6.0 ? .green : .red
        }

        private func gradeRow(label: String, value: String) -> some View {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            return HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if !trimmed.isEmpty {
                    Text(trimmed)
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(gradeColor(value))
                }
            }
        }

        private func gradeColor(_ value: String) -> Color {
            let trimmed = value.trimmingCharacters(in: .whitespaces)
            guard let numericValue = Double(trimmed) else { return .secondary }
            return numericValue >= 6.0 ? .green : .red
        }
    }
}
