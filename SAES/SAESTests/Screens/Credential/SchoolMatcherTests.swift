import XCTest
@testable import SAES

final class SchoolMatcherTests: XCTestCase {
    private let sut = SchoolMatcher.shared

    func test_detectSchool_withParentheses_matchesLongName() {
        let result = sut.detectSchool(from: "ESCUELA SUPERIOR DE CÓMPUTO (ESCOM)")

        XCTAssertEqual(result?.code, .escom)
    }

    func test_detectSchool_withoutParentheses_matchesLongName() {
        let result = sut.detectSchool(from: "ESCUELA SUPERIOR DE CÓMPUTO")

        XCTAssertEqual(result?.code, .escom)
    }

    func test_detectSchool_withNameOnly_matchesName() {
        let result = sut.detectSchool(from: "ESCOM")

        XCTAssertEqual(result?.code, .escom)
    }

    func test_detectSchool_escaSantoTomas_matchesCorrectCampus() {
        let result = sut.detectSchool(from: "ESCA SANTO TOMÁS")

        XCTAssertEqual(result?.code, .escasto)
    }

    func test_detectSchool_escaTepepan_matchesCorrectCampus() {
        let result = sut.detectSchool(from: "ESCA TEPEPAN")

        XCTAssertEqual(result?.code, .escatep)
    }

    func test_detectSchool_cecyt1_doesNotMatchCecyt10() {
        let result = sut.detectSchool(from: "CECyT 1")

        XCTAssertEqual(result?.code, .cecyt1)
    }

    func test_detectSchool_cecyt10_matchesCecyt10() {
        let result = sut.detectSchool(from: "CECyT 10")

        XCTAssertEqual(result?.code, .cecyt10)
    }

    func test_detectSchool_esimeZacatenco_matchesCorrectCampus() {
        let result = sut.detectSchool(from: "ESIME ZACATENCO")

        XCTAssertEqual(result?.code, .esimez)
    }

    func test_detectSchool_credentialFormatWithUnidadTepepan_matchesEscaTepepan() {
        let result = sut.detectSchool(from: "ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan")

        XCTAssertEqual(result?.code, .escatep)
    }

    func test_detectSchool_credentialFormatWithUnidadSantoTomas_matchesEscaSantoTomas() {
        let result = sut.detectSchool(from: "ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Santo Tomás")

        XCTAssertEqual(result?.code, .escasto)
    }

    func test_detectSchool_unknownSchool_returnsNil() {
        let result = sut.detectSchool(from: "ESCUELA DESCONOCIDA")

        XCTAssertNil(result)
    }

    func test_detectSchool_withDiacritics_matchesCorrectly() {
        let result = sut.detectSchool(from: "ESCUELA NACIONAL DE MEDICINA Y HOMEOPATÍA")

        XCTAssertEqual(result?.code, .enmh)
    }

    func test_detectSchool_rawValueAsSubstring_matches() {
        let result = sut.detectSchool(from: "algo escom algo")

        XCTAssertEqual(result?.code, .escom)
    }
}
