import SwiftUI

struct CalendarExportSheet: View {
    @Binding var selectedAlarmOffset: ScheduleCalendarExporter.AlarmOffset
    let isExporting: Bool
    let isAddedToCalendar: Bool
    let onExport: () -> Void
    let onRemove: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: isAddedToCalendar ? "calendar.badge.minus" : "calendar.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.saes)
                .padding(.top, 8)

            VStack(spacing: 8) {
                Text(isAddedToCalendar ? Localization.removeFromCalendar : Localization.addToCalendar)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(isAddedToCalendar ? Localization.calendarRemoveDescription : Localization.calendarExportDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !isAddedToCalendar {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Localization.reminderBeforeClass)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Picker(Localization.reminderBeforeClass, selection: $selectedAlarmOffset) {
                        ForEach(ScheduleCalendarExporter.AlarmOffset.allCases) { offset in
                            Text(offset.displayText).tag(offset)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }

            VStack(spacing: 12) {
                Button {
                    isAddedToCalendar ? onRemove() : onExport()
                } label: {
                    if isExporting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isAddedToCalendar ? Localization.removeFromCalendar : Localization.addToCalendar)
                    }
                }
                .buttonStyle(.filledStyle)
                .tint(isAddedToCalendar ? .red : nil)
                .disabled(isExporting)

                Button {
                    onCancel()
                } label: {
                    Text(Localization.cancel)
                }
                .buttonStyle(.outlinedStyle)
                .disabled(isExporting)
            }
        }
        .padding(24)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
