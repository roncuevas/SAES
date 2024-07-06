import Foundation

struct HorarioSemanal {
    var horarioPorDia: [String: [MateriaConHoras]] = [:]
    
    mutating func agregarMateria(dia: String, materia: String, rangoHoras: String) {
        // Convertir el rango de horas en un arreglo de horas
        let horas = convertirRangoEnHorarios(rangoHoras: rangoHoras)
        
        // Crear o actualizar la lista de materias para el día dado
        let materiaConHoras = MateriaConHoras(materia: materia, horas: horas)
        if horarioPorDia[dia] != nil {
            horarioPorDia[dia]?.append(materiaConHoras)
        } else {
            horarioPorDia[dia] = [materiaConHoras]
        }
    }
    
    func convertirRangoEnHorarios(rangoHoras: String) -> [RangoHorario] {
        var rangosHorarios: [RangoHorario] = []
        
        // Divide la cadena en componentes separados por espacios
        let componentes = rangoHoras.split(separator: " ").map(String.init)
        var rangoTemporal: [String] = []

        for componente in componentes {
            // Agrega el componente actual al rango temporal
            rangoTemporal.append(componente)

            // Si el rango temporal tiene 2 elementos (inicio y fin), procesa este rango
            if rangoTemporal.count == 3 {
                let inicio = rangoTemporal[0]
                let fin = rangoTemporal[2]

                // Crea un nuevo RangoHorario y lo añade a la lista
                let rangoHorario = RangoHorario(inicio: inicio, fin: fin)
                rangosHorarios.append(rangoHorario)

                // Reinicia el rango temporal usando el fin como el nuevo inicio
                // Esto permite manejar cadenas con múltiples rangos
                rangoTemporal.removeAll()
            }
        }

        return rangosHorarios
    }
}
