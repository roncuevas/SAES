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

    // MARK: - New HTML format (inline styles, no .cok/.cdvr)

    func test_parse_newFormat_enrolledStudent_extractsAllFields() throws {
        let html = makeNewFormatEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertEqual(result.studentID, "2023431239")
        XCTAssertEqual(result.studentName, "ALEJANDRA YARETH VEGA CALDERON")
        XCTAssertEqual(result.curp, "VECA020407MMCGLLA2")
        XCTAssertEqual(result.career, "LICENCIATURA EN RELACIONES COMERCIALES")
        XCTAssertEqual(result.school, "ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan")
        XCTAssertTrue(result.isEnrolled)
        XCTAssertEqual(result.cctCode, "09DPN0075I")
    }

    func test_parse_newFormat_enrolledStudent_extractsProfilePicture() throws {
        let html = makeNewFormatEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertNotNil(result.profilePictureBase64)
        XCTAssertTrue(result.profilePictureBase64?.hasPrefix("data:image/jpeg;base64,") ?? false)
    }

    // MARK: - Legacy HTML format (.cok/.cdvr classes)

    func test_parse_legacyFormat_enrolledStudent_extractsAllFields() throws {
        let html = makeLegacyEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertEqual(result.studentID, "2023431239")
        XCTAssertEqual(result.studentName, "ALEJANDRA YARETH VEGA CALDERON")
        XCTAssertTrue(result.isEnrolled)
        XCTAssertEqual(result.cctCode, "09DPN0075I")
    }

    func test_parse_legacyFormat_enrolledWithoutCok_detectsFromCdvr() throws {
        let html = makeLegacyEnrolledWithoutCokHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertTrue(result.isEnrolled)
        XCTAssertEqual(result.cctCode, "09DPN0075I")
    }

    func test_parse_legacyFormat_notEnrolled_detectsStatus() throws {
        let html = makeLegacyNotEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertEqual(result.studentID, "2019520230")
        XCTAssertEqual(result.studentName, "AARON ALBERTO MARTINEZ CUEVAS")
        XCTAssertFalse(result.isEnrolled)
    }

    func test_parse_legacyFormat_noImage_returnsNilProfilePicture() throws {
        let html = makeLegacyNotEnrolledHTML()
        let data = Data(html.utf8)

        let result = try sut.parse(data: data)

        XCTAssertNil(result.profilePictureBase64)
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

    private func makeNewFormatEnrolledHTML() -> String {
        """
        <html><body>
        <div id="wrapper">
        <div class="boleta">2023431239</div>
        <div class="curp">VECA020407MMCGLLA2</div>
        <div class="nombre">ALEJANDRA YARETH VEGA CALDERON</div>
        <div class="carrera">LICENCIATURA EN RELACIONES COMERCIALES</div>
        <div class="escuela">ESCUELA SUPERIOR DE COMERCIO Y ADMINISTRACIÓN (ESCA), Unidad Tepepan</div>
        <img src="data:image/jpeg;base64,/9j/4AAQSkZJRgABAQ==" />
        <font size="12px">Clave del Centro de Trabajo (CCT):<br><b>09DPN0075I</b></font>
        <div style="background-color:#99cfc7; margin:50px; border-radius:15px; padding:20px; font-size:xxx-large"><b>Inscrita</b><br> en el periodo escolar actual.</div>
        </div>
        </body></html>
        """
    }

    private func makeLegacyEnrolledHTML() -> String {
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

    private func makeLegacyEnrolledWithoutCokHTML() -> String {
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

    private func makeLegacyNotEnrolledHTML() -> String {
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
