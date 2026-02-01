import XCTest
@testable import SAES

final class GradeItemExtensionTests: XCTestCase {

    func testTransformToHierarchicalStructureGroupsByGpo() {
        let items: [GradeItem] = [
            GradeItem(gpo: "1CM1", materia: "Matematicas", primerParcial: "10", segundoParcial: "9", tercerParcial: "8", ext: "", final: "9"),
            GradeItem(gpo: "1CM1", materia: "Fisica", primerParcial: "8", segundoParcial: "7", tercerParcial: "9", ext: "", final: "8"),
            GradeItem(gpo: "2CV5", materia: "Quimica", primerParcial: "10", segundoParcial: "10", tercerParcial: "10", ext: "", final: "10"),
        ]

        let grupos = items.transformToHierarchicalStructure()

        XCTAssertEqual(grupos.count, 2)

        let grupo1CM1 = grupos.first(where: { $0.nombre == "1CM1" })
        XCTAssertNotNil(grupo1CM1)
        XCTAssertEqual(grupo1CM1?.materias.count, 2)

        let grupo2CV5 = grupos.first(where: { $0.nombre == "2CV5" })
        XCTAssertNotNil(grupo2CV5)
        XCTAssertEqual(grupo2CV5?.materias.count, 1)
    }

    func testTransformEmptyArrayReturnsEmpty() {
        let items: [GradeItem] = []
        let grupos = items.transformToHierarchicalStructure()
        XCTAssertTrue(grupos.isEmpty)
    }

    func testCalificacionesAreMappedCorrectly() {
        let items: [GradeItem] = [
            GradeItem(gpo: "1CM1", materia: "Matematicas", primerParcial: "10", segundoParcial: "9", tercerParcial: "8", ext: "NP", final: "9"),
        ]

        let grupos = items.transformToHierarchicalStructure()
        let materia = grupos.first?.materias.first
        XCTAssertEqual(materia?.calificaciones.primerParcial, "10")
        XCTAssertEqual(materia?.calificaciones.segundoParcial, "9")
        XCTAssertEqual(materia?.calificaciones.tercerParcial, "8")
        XCTAssertEqual(materia?.calificaciones.ext, "NP")
        XCTAssertEqual(materia?.calificaciones.final, "9")
    }
}
