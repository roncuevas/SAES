import SwiftUI
import WidgetKit

struct ScheduleWidgetView: View {
    let entry: ScheduleEntry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallView
        case .systemMedium:
            mediumView
        case .systemLarge:
            largeView
        default:
            smallView
        }
    }

    // MARK: - Small: Next class

    @ViewBuilder
    private var smallView: some View {
        if entry.isEmpty {
            WidgetEmptyView(icon: "calendar.badge.clock", message: "No hay clases proximas")
        } else if let item = entry.currentClass ?? entry.nextClass {
            HStack(spacing: 0) {
                WidgetColors.color(at: item.colorIndex)
                    .frame(width: 6)
                VStack(alignment: .leading, spacing: 4) {
                    if let current = entry.currentClass, current.id == item.id {
                        Text("AHORA")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(WidgetColors.color(at: item.colorIndex))
                    } else {
                        Text("SIGUIENTE")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    Text(item.materia)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(2)
                    Text(item.timeRange)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let ubicacion = item.ubicacion {
                        Text(ubicacion)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding(.leading, 10)
                .padding(.vertical, 8)
                Spacer(minLength: 0)
            }
        } else {
            WidgetEmptyView(icon: "calendar.badge.clock", message: "No hay clases proximas")
        }
    }

    // MARK: - Medium: All classes (compact)

    @ViewBuilder
    private var mediumView: some View {
        if entry.isEmpty {
            WidgetEmptyView(icon: "calendar.badge.clock", message: "No hay clases proximas")
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(entry.isToday ? "Hoy" : entry.dayName)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(entry.classes.count) clases")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                .padding(.bottom, 6)

                ForEach(entry.classes.prefix(4)) { item in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(WidgetColors.color(at: item.colorIndex))
                            .frame(width: 6, height: 6)
                        Text(item.timeRange)
                            .font(.caption2.monospacedDigit())
                            .foregroundStyle(.secondary)
                            .frame(width: 80, alignment: .leading)
                        Text(item.materia)
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                        Spacer(minLength: 0)
                        if let ubicacion = item.ubicacion {
                            Text(ubicacion)
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 3)
                }

                if entry.classes.count > 4 {
                    Text("+\(entry.classes.count - 4) mas")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }
            .padding(2)
        }
    }

    // MARK: - Large: Full schedule

    @ViewBuilder
    private var largeView: some View {
        if entry.isEmpty {
            WidgetEmptyView(icon: "calendar.badge.clock", message: "No hay clases proximas")
        } else {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(entry.isToday ? "Hoy" : entry.dayName)
                        .font(.headline.weight(.bold))
                    Spacer()
                    Text("\(entry.classes.count) clases")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)

                ForEach(entry.classes.prefix(6)) { item in
                    HStack(spacing: 10) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(WidgetColors.color(at: item.colorIndex))
                            .frame(width: 4)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.materia)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption2)
                                Text(item.timeRange)
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                            if !item.profesores.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "person")
                                        .font(.caption2)
                                    Text(item.profesores)
                                        .font(.caption2)
                                        .lineLimit(1)
                                }
                                .foregroundStyle(.tertiary)
                            }
                            if let ubicacion = item.ubicacion {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin")
                                        .font(.caption2)
                                    Text(ubicacion)
                                        .font(.caption2)
                                        .lineLimit(1)
                                }
                                .foregroundStyle(.tertiary)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(.vertical, 5)
                    if item.id != entry.classes.prefix(6).last?.id {
                        Divider()
                    }
                }

                if entry.classes.count > 6 {
                    Text("+\(entry.classes.count - 6) mas")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
            }
            .padding(2)
        }
    }
}
