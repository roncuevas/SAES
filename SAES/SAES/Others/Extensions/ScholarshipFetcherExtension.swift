import Foundation

extension ScholarshipFetcher {
    func fetchScholarships() async -> IPNScholarshipResponse {
        do {
            return try await NetworkManager.shared.sendRequest(url: URLConstants.ipnScholarships,
                                                               type: IPNScholarshipResponse.self)
        } catch {
            Logger(logLevel: .error).log(level: .error, message: "\(error)", source: "ScholarshipFetcher")
        }
        return IPNScholarshipResponse(success: false, data: IPNScholarshipData(total: 0, nuevas: 0, becas: []))
    }
}
