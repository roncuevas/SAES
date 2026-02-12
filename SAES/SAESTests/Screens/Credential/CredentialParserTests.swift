import XCTest
@testable import SAES

final class CredentialParserTests: XCTestCase {
    private var sut: CredentialParser!

    override func setUp() {
        super.setUp()
        sut = CredentialParser()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Enrolled student

    func test_parse_enrolledStudent_extractsAllFields() throws {
        let html = makeEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertEqual(result.studentID, "2023431239")
        XCTAssertEqual(result.studentName, "ALEJANDRA YARETH VEGA CALDERON")
        XCTAssertEqual(result.curp, "VECA020407MMCGLLA2")
        XCTAssertEqual(result.career, "LICENCIATURA EN RELACIONES COMERCIALES")
        XCTAssertEqual(result.school, "ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan")
        XCTAssertTrue(result.isEnrolled)
    }

    func test_parse_enrolledStudent_extractsProfilePicture() throws {
        let html = makeEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertNotNil(result.profilePictureBase64)
        XCTAssertTrue(result.profilePictureBase64?.hasPrefix("data:image/jpeg;base64,") ?? false)
    }

    func test_parse_noImage_returnsNilProfilePicture() throws {
        let html = makeNotEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertNil(result.profilePictureBase64)
    }

    func test_parse_enrolledStudent_withoutCokElement_detectsFromCdvr() throws {
        let html = makeEnrolledWithoutCokHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertTrue(result.isEnrolled)
        XCTAssertEqual(result.cctCode, "09DPN0075I")
    }

    // MARK: - Not enrolled student

    func test_parse_notEnrolledStudent_detectsStatus() throws {
        let html = makeNotEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertEqual(result.studentID, "2019520230")
        XCTAssertEqual(result.studentName, "AARON ALBERTO MARTINEZ CUEVAS")
        XCTAssertEqual(result.career, "MÉDICO CIRUJANO Y PARTERO")
        XCTAssertFalse(result.isEnrolled)
    }

    // MARK: - Empty/Invalid HTML

    func test_parse_emptyBody_throws() {
        let html = "<html><body></body></html>"
        let data = Data(html.utf8)

        XCTAssertThrowsError(try sut.parse(data: data))
    }

    func test_parse_missingName_throws() {
        let html = """
        <html><body>
        <div id="wrapper">
        <div class="boleta">123</div>
        </div>
        </body></html>
        """
        let data = Data(html.utf8)

        XCTAssertThrowsError(try sut.parse(data: data))
    }

    // MARK: - Helpers

    private func makeEnrolledWithoutCokHTML() -> String {
        """
        <html><body>
        <div id="wrapper">
        <div class="boleta">2023431239</div>
        <div class="curp">VECA020407MMCGLLA2</div>
        <div class="nombre">ALEJANDRA YARETH VEGA CALDERON</div>
        <div class="carrera">LICENCIATURA EN RELACIONES COMERCIALES</div>
        <div class="escuela">ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan</div>
        <div>CCT: <span class="cdvr">09DPN0075I</span></div>
        </div>
        </body></html>
        """
    }

    private func makeEnrolledHTML() -> String {
        """
        <html><body>
        <div id="wrapper">
        <div class="boleta">2023431239</div>
        <div class="curp">VECA020407MMCGLLA2</div>
        <div class="nombre">ALEJANDRA YARETH VEGA CALDERON</div>
        <div class="carrera">LICENCIATURA EN RELACIONES COMERCIALES</div>
        <div class="escuela">ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan</div>
        <img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ==" />
        <div>CCT: <span class="cdvr">09DPN0075I</span></div>
        <div class="cok">Inscrita</div>
        </div>
        </body></html>
        """
    }

    private func makeNotEnrolledHTML() -> String {
        """
        <html><body>
        <div id="wrapper">
        <div class="boleta">2019520230</div>
        <div class="curp">MACA001210HMCRVRA4</div>
        <div class="nombre">AARON ALBERTO MARTINEZ CUEVAS</div>
        <div class="carrera">MÉDICO CIRUJANO Y PARTERO</div>
        <div class="escuela">ESCUELA NACIONAL DE MEDICINA Y HOMEOPATÍA (ENMH)</div>
        <div class="cdvr">CREDENCIAL NO VIGENTE (NO INSCRITO)</div>
        </div>
        </body></html>
        """
    }
}
