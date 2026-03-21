import SwiftUI
import CustomKit

@MainActor
struct ScheduleAvailability: View {
    @StateObject private var viewModel = ScheduleAvailabilityViewModel()

    var body: some View {
        content
            .task {
                await AnalyticsManager.shared.logScreen("scheduleAvailability")
                await viewModel.getData()
            }
    }

    private var content: some View {
        LoadingStateView(
            loadingState: viewModel.loadingState,
            searchingTitle: Localization.searchingForPersonalData,
            retryAction: { Task { await viewModel.getData() } }
        ) {
            loadedContent
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
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                }
                if let name = subject.name {
                    Text(name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                if let teacher = subject.teacher {
                    Text(teacher)
                        .font(.caption)
                        .foregroundStyle(.primary)
                        .padding(.bottom, 4)
                }
                Text("\(subject.building?.space.dash.space ?? "N/A")\(subject.classroom ?? "N/A")")
                    .font(.caption)
                    .foregroundStyle(.primary)
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
