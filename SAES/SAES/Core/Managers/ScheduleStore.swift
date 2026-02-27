import Foundation
import SwiftUI

@MainActor
final class ScheduleStore: ObservableObject {
    static let shared = ScheduleStore()

    @Published private(set) var scheduleItems: [ScheduleItem] = []
    @Published private(set) var horarioSemanal = HorarioSemanal()

    var hasData: Bool { !scheduleItems.isEmpty }

    private init() {}

    func update(items: [ScheduleItem], horario: HorarioSemanal) {
        scheduleItems = items
        horarioSemanal = horario
    }

    func clear() {
        scheduleItems = []
        horarioSemanal = HorarioSemanal()
    }
}
