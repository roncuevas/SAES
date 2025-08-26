import SwiftUI
import CustomKit

struct ScheduleAvailability: View {
    @StateObject private var viewModel = ScheduleAvailabilityViewModel()

    var body: some View {
        content
            .task {
                await viewModel.getData()
            }
            .onChange(of: viewModel.selectedCareer) { newValue in
                print(newValue)
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.loadingState {
        case .idle:
            Color.clear
        case .loading:
            SearchingView(title: Localization.searchingForPersonalData)
        case .loaded:
            loadedContent
        default:
            NoContentView {
                Task {
                    await viewModel.getData()
                }
            }
        }
    }

    private var loadedContent: some View {
        List {
            Section("Buscar disponibilidad") {
                Picker("Carrera", selection: $viewModel.selectedCareer) {
                    ForEach(viewModel.careers) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                Picker("Plan de estudios", selection: $viewModel.selectedStudyPlan) {
                    ForEach(viewModel.studyPlans) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                Picker("Periodo", selection: $viewModel.selectedPeriod) {
                    ForEach(viewModel.periods) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                Picker("Turno", selection: $viewModel.selectedShift) {
                    ForEach(viewModel.shifts) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                HStack {
                    Spacer()
                    Button("Buscar") {
                        Task {
                            await viewModel.search()
                        }
                    }
                    Spacer()
                }
            }
            .pickerStyle(.menu)

            Section("Resultados") {
                HStack {
                    VStack(alignment: .leading) {
                        Text("8PM8SS")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        Text("PRINCIPIOS Y APLICACIONES DE LOS NEGOCIOS INTERNACIONALES")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("ALCANTARA GONZALEZ ANITA")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)
                        Text("CS - 000")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    VStack {
                        Text("Lun: 07:00 - 09:00")
                        Text("Lun: 07:00 - 09:00")
                        Text("Lun: 07:00 - 09:00")
                        Text("Lun: 07:00 - 09:00")
                        Text("Lun: 07:00 - 09:00")
                    }
                    .font(.caption)
                }
            }
        }
    }
}
