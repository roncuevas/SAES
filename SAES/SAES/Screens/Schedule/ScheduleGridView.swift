import SwiftUI

struct ScheduleGridView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @State private var currentTime = Date()

    private let hourHeight: CGFloat = 80
    private let timeColumnWidth: CGFloat = 36
    private let headerHeight: CGFloat = 32

    private var dayCount: Int {
        viewModel.hasSaturdayClasses ? 6 : 5
    }

    private var dayHeaders: [String] {
        let all: [SAESDays] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        return Array(all.prefix(dayCount)).map { $0.shortName.uppercased() }
    }

    private var startHour: Int { viewModel.gridStartHour }
    private var endHour: Int { viewModel.gridEndHour }
    private var totalHours: Int { max(endHour - startHour, 1) }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let dayColumnWidth = (geometry.size.width - timeColumnWidth) / CGFloat(dayCount)
                let totalHeight = headerHeight + CGFloat(totalHours) * hourHeight

                ScrollView(.vertical) {
                    ZStack(alignment: .topLeading) {
                        gridBackground(dayColumnWidth: dayColumnWidth, totalWidth: geometry.size.width)
                        blocksOverlay(dayColumnWidth: dayColumnWidth)
                        currentTimeLine(totalWidth: geometry.size.width)
                    }
                    .frame(width: geometry.size.width, height: totalHeight)
                }
            }

            legend
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
        .onAppear { currentTime = Date() }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(60))
                currentTime = Date()
            }
        }
    }

    // MARK: - Grid background

    private func gridBackground(dayColumnWidth: CGFloat, totalWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            dayHeaderRow(dayColumnWidth: dayColumnWidth)
            ZStack(alignment: .topLeading) {
                hourLines(totalWidth: totalWidth)
                verticalLines(dayColumnWidth: dayColumnWidth)
                hourLabels
            }
            .frame(height: CGFloat(totalHours) * hourHeight)
        }
    }

    private func dayHeaderRow(dayColumnWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: timeColumnWidth, height: headerHeight)
            ForEach(dayHeaders, id: \.self) { header in
                Text(header)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: dayColumnWidth, height: headerHeight)
            }
        }
    }

    // MARK: - Grid lines

    private func hourLines(totalWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(hourRange, id: \.self) { _ in
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: totalWidth - timeColumnWidth, height: 0.5)
                    Spacer()
                }
                .frame(height: hourHeight)
            }
        }
        .padding(.leading, timeColumnWidth)
    }

    private func verticalLines(dayColumnWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(0...dayCount, id: \.self) { index in
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 0.5)
                    .offset(x: timeColumnWidth + CGFloat(index) * dayColumnWidth)
            }
        }
        .frame(height: CGFloat(totalHours) * hourHeight)
    }

    private var hourLabels: some View {
        VStack(spacing: 0) {
            ForEach(hourRange, id: \.self) { hour in
                HStack {
                    Text("\(hour):00")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(width: timeColumnWidth - 2, alignment: .trailing)
                    Spacer()
                }
                .frame(height: hourHeight, alignment: .top)
                .offset(y: -6)
            }
        }
    }

    // MARK: - Current time indicator

    private func currentTimeLine(totalWidth: CGFloat) -> some View {
        let now = currentTimeMinutes
        let isVisible = now >= startHour * 60 && now < endHour * 60

        let lineY = headerHeight + yOffset(for: now)

        return Group {
            if isVisible {
                ZStack(alignment: .topLeading) {
                    Text(currentTimeString)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(Color.saes)
                        .clipShape(.rect(cornerRadius: 3))
                        .offset(x: 1, y: lineY - 7)

                    Rectangle()
                        .fill(Color.saes)
                        .frame(width: totalWidth - timeColumnWidth, height: 1.5)
                        .offset(x: timeColumnWidth, y: lineY)

                    Circle()
                        .fill(Color.saes)
                        .frame(width: 8, height: 8)
                        .offset(x: timeColumnWidth - 4, y: lineY - 3.5)
                }
            }
        }
    }

    private var currentTimeMinutes: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: currentTime)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private var currentTimeString: String {
        let hour = currentTimeMinutes / 60
        let minute = currentTimeMinutes % 60
        return String(format: "%d:%02d", hour, minute)
    }

    // MARK: - Class blocks

    private func blocksOverlay(dayColumnWidth: CGFloat) -> some View {
        ForEach(viewModel.gridBlocks) { block in
            blockView(for: block)
                .frame(
                    width: dayColumnWidth - 4,
                    height: max(CGFloat(block.duracionMinutos) / 60.0 * hourHeight, 30)
                )
                .offset(
                    x: timeColumnWidth + CGFloat(block.dayIndex) * dayColumnWidth + 2,
                    y: headerHeight + yOffset(for: block.inicioMinutos)
                )
        }
    }

    private func blockView(for block: ScheduleGridBlock) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(block.materia)
                .font(.caption2)
                .bold()
                .fixedSize(horizontal: false, vertical: true)

            Text("\(block.inicio)-\(block.fin)")
                .font(.system(size: 9))
                .lineLimit(1)

            if let salon = block.salon {
                Text(salon)
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
        }
        .padding(4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(.white)
        .background(block.color.opacity(0.85))
        .clipShape(.rect(cornerRadius: 6))
    }

    // MARK: - Legend

    private var legend: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 16) {
                ForEach(viewModel.subjectColors, id: \.materia) { entry in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(entry.color)
                            .frame(width: 8, height: 8)
                        Text(entry.materia.localizedCapitalized)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Helpers

    private var hourRange: [Int] {
        Array(startHour..<endHour)
    }

    private func yOffset(for minutes: Int) -> CGFloat {
        CGFloat(minutes - startHour * 60) / 60.0 * hourHeight
    }
}
