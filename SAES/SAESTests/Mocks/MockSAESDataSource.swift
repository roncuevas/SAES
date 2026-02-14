import Foundation
@testable import SAES

final class MockSAESDataSource: SAESDataSource, @unchecked Sendable {
    var result: Result<Data, Error> = .success(Data())
    var fetchCallCount = 0

    func fetch() async throws -> Data {
        fetchCallCount += 1
        return try result.get()
    }
}
