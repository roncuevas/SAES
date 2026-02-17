import XCTest
@testable import SAES

@MainActor
final class ScheduleViewModelTests: XCTestCase {
    private var mockDataSource: MockSAESDataSource!
    private var sut: ScheduleViewModel!

    override func setUp() {
        super.setUp()
        mockDataSource = MockSAESDataSource()
    }

    override func tearDown() {
        mockDataSource = nil
        sut = nil
        super.tearDown()
    }

    private func makeSUT() -> ScheduleViewModel {
        ScheduleViewModel(
            dataSource: mockDataSource
        )
    }

    // MARK: - ScheduleViewModel Tests

    func test_getSchedule_idleState_initially() {
        sut = makeSUT()

        XCTAssertEqual(sut.loadingState, .idle)
        XCTAssertTrue(sut.schedule.isEmpty)
    }

    func test_getSchedule_success_setsLoadedState() async {
        let html = Self.validScheduleHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getSchedule()

        XCTAssertEqual(sut.loadingState, .loaded)
        XCTAssertEqual(sut.schedule.count, 2)
        XCTAssertFalse(sut.horarioSemanal.horarioPorDia.isEmpty)
    }

    func test_getSchedule_networkError_setsEmptyState() async {
        mockDataSource.result = .failure(URLError(.notConnectedToInternet))
        sut = makeSUT()

        await sut.getSchedule()

        // performLoading sets .noNetwork, but the catch block overrides to .empty
        XCTAssertEqual(sut.loadingState, .empty)
    }

    func test_getSchedule_emptyTable_setsEmptyState() async {
        let html = """
        <table id="ctl00_mainCopy_GV_Horario">
          <tr><th>Grupo</th></tr>
        </table>
        """
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getSchedule()

        XCTAssertEqual(sut.loadingState, .empty)
        XCTAssertTrue(sut.schedule.isEmpty)
    }

    func test_getSchedule_callsFetchOnce() async {
        let html = Self.validScheduleHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getSchedule()

        XCTAssertEqual(mockDataSource.fetchCallCount, 1)
    }

    func test_getSchedule_buildsHorarioSemanal() async {
        let html = Self.validScheduleHTML
        mockDataSource.result = .success(Data(html.utf8))
        sut = makeSUT()

        await sut.getSchedule()

        XCTAssertNotNil(sut.horarioSemanal.horarioPorDia["Lunes"])
        XCTAssertNotNil(sut.horarioSemanal.horarioPorDia["Miercoles"])
        XCTAssertNotNil(sut.horarioSemanal.horarioPorDia["Martes"])
        XCTAssertNotNil(sut.horarioSemanal.horarioPorDia["Jueves"])
    }

    // MARK: - Fixture

    private static let validScheduleHTML = """
    <table id="ctl00_mainCopy_GV_Horario">
      <tr>
        <th>Grupo</th><th>Materia</th><th>Profesores</th>
        <th>Lunes</th><th>Martes</th><th>Miércoles</th>
        <th>Jueves</th><th>Viernes</th>
      </tr>
      <tr>
        <td>3CM1</td><td>PROBABILIDAD</td><td>GARCIA LOPEZ JUAN</td>
        <td>7:00 - 8:30<br>Edif: 2 - Salón: 109</td><td></td><td>7:00 - 8:30<br>Edif: 2 - Salón: 109</td>
        <td></td><td></td>
      </tr>
      <tr>
        <td>3CM1</td><td>BASES DE DATOS</td><td>PEREZ MARTINEZ ANA</td>
        <td></td><td>10:30 - 12:00<br>Edif: 1 - Salón: 113</td><td></td>
        <td>10:30 - 12:00<br>Edif: 1 - Salón: 113</td><td></td>
      </tr>
    </table>
    """
}

// MARK: - ScheduleParser Tests

@MainActor
final class ScheduleParserTests: XCTestCase {

    func test_parseSchedule_validHTML_returnsItems() throws {
        let parser = ScheduleParser()
        let html = """
        <table id="ctl00_mainCopy_GV_Horario">
          <tr>
            <th>Grupo</th><th>Materia</th><th>Profesores</th>
            <th>Lunes</th><th>Martes</th><th>Miércoles</th>
            <th>Jueves</th><th>Viernes</th>
          </tr>
          <tr>
            <td>3CM1</td><td>PROBABILIDAD</td><td>GARCIA LOPEZ JUAN</td>
            <td>7:00 - 8:30<br>Edif: 2 - Salón: 109</td><td></td><td>7:00 - 8:30<br>Edif: 2 - Salón: 109</td>
            <td></td><td></td>
          </tr>
          <tr>
            <td>3CM1</td><td>BASES DE DATOS</td><td>PEREZ MARTINEZ ANA</td>
            <td></td><td>10:30 - 12:00<br>Edif: 1 - Salón: 113</td><td></td>
            <td>10:30 - 12:00<br>Edif: 1 - Salón: 113</td><td></td>
          </tr>
        </table>
        """
        let data = Data(html.utf8)

        let items = try parser.parseSchedule(data)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].materia, "PROBABILIDAD")
        XCTAssertEqual(items[0].grupo, "3CM1")
        XCTAssertEqual(items[0].lunes, "7:00 - 8:30")
        XCTAssertEqual(items[0].miercoles, "7:00 - 8:30")
        XCTAssertEqual(items[0].edificio, "2")
        XCTAssertEqual(items[0].salon, "109")
        XCTAssertEqual(items[1].materia, "BASES DE DATOS")
        XCTAssertEqual(items[1].martes, "10:30 - 12:00")
        XCTAssertEqual(items[1].edificio, "1")
        XCTAssertEqual(items[1].salon, "113")
    }

    func test_parseSchedule_noTable_throwsError() {
        let parser = ScheduleParser()
        let html = "<html><body><p>No table here</p></body></html>"
        let data = Data(html.utf8)

        XCTAssertThrowsError(try parser.parseSchedule(data)) { error in
            XCTAssertTrue(error is ScheduleError)
        }
    }

    func test_parseSchedule_headerNormalization() throws {
        let parser = ScheduleParser()
        let html = """
        <table id="ctl00_mainCopy_GV_Horario">
          <tr>
            <th>Grupo</th><th>Materia</th><th>Profesores</th>
            <th>Lunes</th><th>Martes</th><th>Miércoles</th>
            <th>Jueves</th><th>Viernes</th><th>Sábado</th>
          </tr>
          <tr>
            <td>1AV1</td><td>CALCULO</td><td>PROF A</td>
            <td></td><td></td><td>9:00 - 10:30<br>Edif: 3 - Salón: 201</td>
            <td></td><td></td><td></td>
          </tr>
        </table>
        """
        let data = Data(html.utf8)

        let items = try parser.parseSchedule(data)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].miercoles, "9:00 - 10:30")
        XCTAssertEqual(items[0].edificio, "3")
        XCTAssertEqual(items[0].salon, "201")
        XCTAssertEqual(items[0].sabado, "")
    }

    func test_parseSchedule_withoutLocation_leavesEdificioNil() throws {
        let parser = ScheduleParser()
        let html = """
        <table id="ctl00_mainCopy_GV_Horario">
          <tr>
            <th>Grupo</th><th>Materia</th><th>Profesores</th>
            <th>Lunes</th><th>Martes</th>
          </tr>
          <tr>
            <td>2AV1</td><td>CALCULO</td><td>PROF B</td>
            <td>8:00 - 9:30</td><td></td>
          </tr>
        </table>
        """
        let data = Data(html.utf8)

        let items = try parser.parseSchedule(data)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].lunes, "8:00 - 9:30")
        XCTAssertNil(items[0].edificio)
        XCTAssertNil(items[0].salon)
    }
}
