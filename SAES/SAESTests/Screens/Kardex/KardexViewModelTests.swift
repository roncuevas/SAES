import XCTest
@testable import SAES

@MainActor
final class KardexViewModelTests: XCTestCase {
    private var mockDataSource: MockSAESDataSource!
    private var sut: KardexViewModel!

    override func setUp() {
        super.setUp()
        mockDataSource = MockSAESDataSource()
    }

    override func tearDown() {
        mockDataSource = nil
        sut = nil
        super.tearDown()
    }

    private func makeSUT() -> KardexViewModel {
        KardexViewModel(dataSource: mockDataSource)
    }

    // MARK: - KardexViewModel Tests

    func test_getKardex_idleState_initially() {
        sut = makeSUT()

        XCTAssertEqual(sut.loadingState, .idle)
        XCTAssertNil(sut.kardexModel)
    }

    func test_getKardex_success_setsLoadedState() async {
        let html = Self.validKardexHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getKardex()

        XCTAssertEqual(sut.loadingState, .loaded)
        XCTAssertNotNil(sut.kardexModel)
    }

    func test_getKardex_networkError_setsErrorState() async {
        mockDataSource.result = .failure(URLError(.notConnectedToInternet))
        sut = makeSUT()

        await sut.getKardex()

        XCTAssertEqual(sut.loadingState, .error)
    }

    func test_getKardex_callsFetchOnce() async {
        let html = Self.validKardexHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getKardex()

        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
    }

    func test_getKardex_parsesCarreraAndPromedio() async {
        let html = Self.validKardexHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getKardex()

        XCTAssertEqual(sut.kardexModel?.carrera, "ING. EN SISTEMAS COMPUTACIONALES")
        XCTAssertEqual(sut.kardexModel?.plan, "2020")
        XCTAssertEqual(sut.kardexModel?.promedio, "8.5")
    }

    // MARK: - Fixture

    private static let validKardexHTML = """
    <div id="ctl00_mainCopy_Panel1">
      <span id="ctl00_mainCopy_Lbl_Carrera">ING. EN SISTEMAS COMPUTACIONALES</span>
      <span id="ctl00_mainCopy_Lbl_Plan">2020</span>
      <span id="ctl00_mainCopy_Lbl_Promedio">8,5</span>
      <div id="ctl00_mainCopy_Lbl_Kardex">
        <center>
          <table>
            <tr><td>PRIMER SEMESTRE</td></tr>
            <tr><th>Clave</th><th>Materia</th><th>Fecha</th><th>Periodo</th><th>Forma Eval</th><th>Calif</th></tr>
            <tr><td>CM01</td><td>CALCULO I</td><td>01/2021</td><td>21/1</td><td>ORD</td><td>9</td></tr>
            <tr><td>CM02</td><td>ALGEBRA LINEAL</td><td>01/2021</td><td>21/1</td><td>ORD</td><td>8</td></tr>
          </table>
        </center>
      </div>
    </div>
    """
}

// MARK: - KardexParser Tests

@MainActor
final class KardexParserTests: XCTestCase {

    func test_parseKardex_validHTML_returnsModel() throws {
        let parser = KardexParser()
        let html = """
        <div id="ctl00_mainCopy_Panel1">
          <span id="ctl00_mainCopy_Lbl_Carrera">ING. EN SISTEMAS COMPUTACIONALES</span>
          <span id="ctl00_mainCopy_Lbl_Plan">2020</span>
          <span id="ctl00_mainCopy_Lbl_Promedio">8,5</span>
          <div id="ctl00_mainCopy_Lbl_Kardex">
            <center>
              <table>
                <tr><td>PRIMER SEMESTRE</td></tr>
                <tr><th>Clave</th><th>Materia</th><th>Fecha</th><th>Periodo</th><th>Forma Eval</th><th>Calif</th></tr>
                <tr><td>CM01</td><td>CALCULO I</td><td>01/2021</td><td>21/1</td><td>ORD</td><td>9</td></tr>
                <tr><td>CM02</td><td>ALGEBRA LINEAL</td><td>01/2021</td><td>21/1</td><td>ORD</td><td>8</td></tr>
              </table>
            </center>
          </div>
        </div>
        """
        let data = Data(html.utf8)

        let model = try parser.parseKardex(data)

        XCTAssertEqual(model.carrera, "ING. EN SISTEMAS COMPUTACIONALES")
        XCTAssertEqual(model.plan, "2020")
        XCTAssertEqual(model.promedio, "8.5")
        XCTAssertEqual(model.kardex?.count, 1)
        XCTAssertEqual(model.kardex?.first?.semestre, "PRIMER SEMESTRE")
        XCTAssertEqual(model.kardex?.first?.materias?.count, 2)
        XCTAssertEqual(model.kardex?.first?.materias?[0].materia, "CALCULO I")
        XCTAssertEqual(model.kardex?.first?.materias?[0].calificacion, "9")
        XCTAssertEqual(model.kardex?.first?.materias?[1].materia, "ALGEBRA LINEAL")
        XCTAssertEqual(model.kardex?.first?.materias?[1].clave, "CM02")
    }

    func test_parseKardex_noPanel_throwsError() {
        let parser = KardexParser()
        let html = "<html><body><p>No panel here</p></body></html>"
        let data = Data(html.utf8)

        XCTAssertThrowsError(try parser.parseKardex(data)) { error in
            XCTAssertTrue(error is KardexError)
        }
    }

    func test_parseKardex_promedioReplacesComma() throws {
        let parser = KardexParser()
        let html = """
        <div id="ctl00_mainCopy_Panel1">
          <span id="ctl00_mainCopy_Lbl_Carrera">CARRERA</span>
          <span id="ctl00_mainCopy_Lbl_Plan">2020</span>
          <span id="ctl00_mainCopy_Lbl_Promedio">9,3</span>
          <div id="ctl00_mainCopy_Lbl_Kardex">
            <center>
              <table>
                <tr><td>PRIMER SEMESTRE</td></tr>
                <tr><th>Clave</th><th>Materia</th><th>Fecha</th><th>Periodo</th><th>Forma Eval</th><th>Calif</th></tr>
                <tr><td>C1</td><td>MAT</td><td>01/2021</td><td>21/1</td><td>ORD</td><td>10</td></tr>
              </table>
            </center>
          </div>
        </div>
        """
        let data = Data(html.utf8)

        let model = try parser.parseKardex(data)

        XCTAssertEqual(model.promedio, "9.3")
    }
}
