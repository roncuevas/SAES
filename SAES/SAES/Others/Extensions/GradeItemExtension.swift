import Foundation

extension [GradeItem] {
    func transformToHierarchicalStructure() -> [Grupo] {
        var gruposDict: [String: [Materia]] = [:]
        for grade in self {
            let calificaciones = Calificacion(
                primerParcial: grade.primerParcial,
                segundoParcial: grade.segundoParcial,
                tercerParcial: grade.tercerParcial,
                ext: grade.ext,
                final: grade.final
            )
            let materia = Materia(nombre: grade.materia, calificaciones: calificaciones)
            
            if gruposDict[grade.gpo] != nil {
                gruposDict[grade.gpo]?.append(materia)
            } else {
                gruposDict[grade.gpo] = [materia]
            }
        }
        var grupos: [Grupo] = []
        for (nombreGrupo, materias) in gruposDict {
            let grupo = Grupo(nombre: nombreGrupo, materias: materias)
            grupos.append(grupo)
        }
        return grupos
    }
}
