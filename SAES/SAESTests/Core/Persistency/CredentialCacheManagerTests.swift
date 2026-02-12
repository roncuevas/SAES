import XCTest
@testable import SAES

final class CredentialCacheManagerTests: XCTestCase {
    private var sut: CredentialCacheManager!

    override func setUp() {
        super.setUp()
        sut = CredentialCacheManager()
    }

    override func tearDown() {
        cleanUpCache(for: "test_school")
        cleanUpCache(for: "school_a")
        cleanUpCache(for: "school_b")
        sut = nil
        super.tearDown()
    }

    // MARK: - load

    func test_load_whenNoCachedData_returnsNil() {
        let result = sut.load("test_school")

        XCTAssertNil(result)
    }

    // MARK: - save + load

    func test_save_thenLoad_returnsSavedData() {
        let webData = makeTestWebData()

        sut.save("test_school", data: webData)
        let result = sut.load("test_school")

        XCTAssertEqual(result, webData)
    }

    func test_save_overwritesPreviousData() {
        let first = makeTestWebData(name: "FIRST")
        let second = makeTestWebData(name: "SECOND")

        sut.save("test_school", data: first)
        sut.save("test_school", data: second)
        let result = sut.load("test_school")

        XCTAssertEqual(result?.studentName, "SECOND")
    }

    // MARK: - delete

    func test_delete_removesCachedData() {
        let webData = makeTestWebData()
        sut.save("test_school", data: webData)

        sut.delete("test_school")
        let result = sut.load("test_school")

        XCTAssertNil(result)
    }

    // MARK: - Isolation

    func test_load_withDifferentSchoolCodes_returnsCorrectData() {
        let dataA = makeTestWebData(name: "STUDENT A")
        let dataB = makeTestWebData(name: "STUDENT B")

        sut.save("school_a", data: dataA)
        sut.save("school_b", data: dataB)

        XCTAssertEqual(sut.load("school_a")?.studentName, "STUDENT A")
        XCTAssertEqual(sut.load("school_b")?.studentName, "STUDENT B")
    }

    // MARK: - Field persistence

    func test_save_persistsAllFields() {
        let webData = CredentialWebData(
            studentID: "2020630999",
            studentName: "MARIA LOPEZ HERNANDEZ",
            curp: "LOHM000202MDFPRR05",
            career: "INGENIERÍA MECATRÓNICA",
            school: "UPIITA",
            cctCode: "09DPN0099Z",
            isEnrolled: false,
            statusText: "CREDENCIAL NO VIGENTE",
            profilePictureBase64: "data:image/png;base64,abc123"
        )

        sut.save("test_school", data: webData)
        let result = sut.load("test_school")

        XCTAssertEqual(result?.studentID, "2020630999")
        XCTAssertEqual(result?.studentName, "MARIA LOPEZ HERNANDEZ")
        XCTAssertEqual(result?.curp, "LOHM000202MDFPRR05")
        XCTAssertEqual(result?.career, "INGENIERÍA MECATRÓNICA")
        XCTAssertEqual(result?.school, "UPIITA")
        XCTAssertEqual(result?.cctCode, "09DPN0099Z")
        XCTAssertEqual(result?.isEnrolled, false)
        XCTAssertEqual(result?.statusText, "CREDENCIAL NO VIGENTE")
        XCTAssertEqual(result?.profilePictureBase64, "data:image/png;base64,abc123")
    }

    // MARK: - Helpers

    private func makeTestWebData(
        studentID: String = "2020630123",
        name: String = "JUAN PEREZ GARCIA",
        career: String = "INGENIERÍA EN SISTEMAS COMPUTACIONALES",
        school: String = "ESCUELA SUPERIOR DE CÓMPUTO (ESCOM)",
        isEnrolled: Bool = true
    ) -> CredentialWebData {
        CredentialWebData(
            studentID: studentID,
            studentName: name,
            curp: "PEGJ000101HMCRRN01",
            career: career,
            school: school,
            cctCode: "09DPN0085X",
            isEnrolled: isEnrolled,
            statusText: isEnrolled ? "09DPN0085X" : "CREDENCIAL NO VIGENTE",
            profilePictureBase64: nil
        )
    }

    private func cleanUpCache(for schoolCode: String) {
        sut?.delete(schoolCode)
    }
}
