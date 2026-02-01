import XCTest
@testable import SAES

final class GradeItemCodableTests: XCTestCase {

    func testDecodeGradeItem() throws {
        let json = """
        {
            "gpo": "1CM1",
            "materia": "Matematicas",
            "1er_parcial": "10",
            "2o_parcial": "9",
            "3er_parcial": "8",
            "ext": "",
            "final": "9"
        }
        """
        let data = json.data(using: .utf8)!
        let item = try JSONDecoder().decode(GradeItem.self, from: data)
        XCTAssertEqual(item.gpo, "1CM1")
        XCTAssertEqual(item.materia, "Matematicas")
        XCTAssertEqual(item.primerParcial, "10")
        XCTAssertEqual(item.segundoParcial, "9")
        XCTAssertEqual(item.tercerParcial, "8")
        XCTAssertEqual(item.final, "9")
    }

    func testEncodeGradeItem() throws {
        let item = GradeItem(
            gpo: "2CV5",
            materia: "Fisica",
            primerParcial: "8",
            segundoParcial: "7",
            tercerParcial: "6",
            ext: "NP",
            final: "7"
        )
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(GradeItem.self, from: data)
        XCTAssertEqual(decoded.gpo, item.gpo)
        XCTAssertEqual(decoded.materia, item.materia)
        XCTAssertEqual(decoded.final, item.final)
    }
}
