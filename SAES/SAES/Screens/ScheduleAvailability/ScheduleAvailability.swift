import SwiftUI
import CustomKit

struct ScheduleAvailability: View {
    @StateObject private var viewModel = ScheduleAvailabilityViewModel()

    var body: some View {
        content
            .task {
                await viewModel.getData()
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
            NoContentView(action: {
                Task {
                    await viewModel.getData()
                }
            })
        }
    }

    private var loadedContent: some View {
        Form {
            Section(Localization.searchAvailability) {
                Picker(Localization.degree, selection: $viewModel.selectedCareer) {
                    ForEach(viewModel.careers) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }

                Picker(Localization.studyPlan, selection: $viewModel.selectedStudyPlan) {
                    ForEach(viewModel.studyPlans) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                Picker(Localization.period, selection: $viewModel.selectedPeriod) {
                    ForEach(viewModel.periods) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
                Picker(Localization.shift, selection: $viewModel.selectedShift) {
                    ForEach(viewModel.shifts) { field in
                        Text(field.text ?? "nofield")
                            .tag(field)
                    }
                }
            }
            .pickerStyle(.menu)

            Section {
                Button(Localization.search) {
                    Task {
                        await viewModel.search()
                    }
                }
            }

            if !viewModel.subjects.isEmpty {
                Section(Localization.results) {
                    ForEach(viewModel.subjects) { subject in
                        subjectView(subject)
                    }
                }
            }
        }
    }

    private func subjectView(_ subject: SAESScheduleSubject) -> some View {
        HStack {
            VStack(alignment: .leading) {
                if let group = subject.group {
                    Text(group)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 4)
                }
                if let name = subject.name {
                    Text(name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                }
                if let teacher = subject.teacher {
                    Text(teacher)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                }
                Text("\(subject.building?.space.dash.space ?? "N/A")\(subject.classroom ?? "N/A")")
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            Spacer()
            if let schedule = subject.schedule {
                VStack {
                    ForEach(schedule) { slot in
                        slotView(slot)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func slotView(_ slot: SAESDailySchedule) -> some View {
        if let day = slot.day?.shortName,
           let time = slot.time,
           time.contains("-") {
            Text("\(day.colon.space)\(time)")
                .font(.caption)
        }
    }
}
