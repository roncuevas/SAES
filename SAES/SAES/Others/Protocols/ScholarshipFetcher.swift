import Foundation

protocol ScholarshipFetcher: Sendable {
    func fetchScholarships() async throws -> IPNScholarshipResponse
}
