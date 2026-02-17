import SwiftUI

struct ScheduleGridBlock: Identifiable {
    let id = UUID()
    let materia: String
    let salon: String?
    let inicio: String
    let fin: String
    let dayIndex: Int
    let color: Color
    let inicioMinutos: Int
    let finMinutos: Int

    var duracionMinutos: Int {
        finMinutos - inicioMinutos
    }

    init(materia: String, salon: String?, inicio: String, fin: String, dayIndex: Int, color: Color) {
        self.materia = materia
        self.salon = salon
        self.inicio = inicio
        self.fin = fin
        self.dayIndex = dayIndex
        self.color = color
        self.inicioMinutos = Self.minutosDesdeMedianoche(inicio)
        self.finMinutos = Self.minutosDesdeMedianoche(fin)
    }

    private static func minutosDesdeMedianoche(_ horario: String) -> Int {
        let componentes = horario.split(separator: ":").map { Int($0) ?? 0 }
        guard componentes.count >= 2 else { return 0 }
        return (componentes[0] * 60) + componentes[1]
    }
}
