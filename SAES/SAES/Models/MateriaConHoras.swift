import Foundation

struct MateriaConHoras: Sendable {
    var materia: String
    var horas: [RangoHorario]  // Usamos String para manejar correctamente las horas y minutos
}
