import Foundation
// Definición de la estructura que representa un ítem de horario con todos los días.
struct ScheduleItem: Decodable {
    var grupo: String
    var materia: String
    var profesores: String
    
    // Ahora cada día tiene su propio objeto `ScheduleDay` con horas y rangos.
    var lunes: String?
    var martes: String?
    var miercoles: String?
    var jueves: String?
    var viernes: String?
    var sabado: String?
}
