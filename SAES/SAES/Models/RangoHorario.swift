import Foundation

struct RangoHorario {
    var inicio: String
    var fin: String
    
    // Función para convertir un horario de tipo String a minutos desde medianoche.
    func minutosDesdeMedianocheDe(_ horario: String) -> Int {
        let componentes = horario.split(separator: ":").map { Int($0) ?? 0 }
        return (componentes[0] * 60) + componentes[1] // Horas * 60 + minutos
    }
    
    // Función para comparar si un rango inicia antes que otro basado en la hora de inicio.
    static func esMenorQue(_ lhs: RangoHorario?, _ rhs: RangoHorario?) -> Bool {
        guard let lhs, let rhs else { return false }
        return lhs.minutosDesdeMedianocheDe(lhs.inicio) < rhs.minutosDesdeMedianocheDe(rhs.inicio)
    }
}
