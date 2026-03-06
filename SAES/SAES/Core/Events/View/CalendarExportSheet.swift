import SwiftUI

struct CalendarExportSheet: View {
    @ObservedObject private var exporter = ScheduleCalendarExporter.shared

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: exporter.isAddedToCalendar ? "calendar.badge.minus" : "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.saes)
                .padding(.top, 8)

            VStack(spacing: 8) {
                Text(exporter.isAddedToCalendar ? Localization.removeFromCalendar : Localization.addToCalendar)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(exporter.isAddedToCalendar ? Localization.calendarRemoveDescription : Localization.calendarExportDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !exporter.isAddedToCalendar {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Localization.reminderBeforeClass)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker(Localization.reminderBeforeClass, selection: $exporter.selectedAlarmOffset) {
                        ForEach(ScheduleCalendarExporter.AlarmOffset.allCases) { offset in
                            Text(offset.displayText).tag(offset)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            VStack(spacing: 12) {
                Button {
                    exporter.isAddedToCalendar ? exporter.handleRemove() : exporter.handleExport()
                } label: {
                    if exporter.isExporting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(exporter.isAddedToCalendar ? Localization.removeFromCalendar : Localization.addToCalendar)
                    }
                }
                .buttonStyle(.filledStyle)
                .tint(exporter.isAddedToCalendar ? .red : nil)
                .disabled(exporter.isExporting)

                Button {
                    exporter.showSheet = false
                } label: {
                    Text(Localization.cancel)
                }
                .buttonStyle(.outlinedStyle)
                .disabled(exporter.isExporting)
            }
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
