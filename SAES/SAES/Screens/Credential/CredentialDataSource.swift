import Foundation

struct CredentialDataSource {
    let qrURL: String

    func fetch() async throws -> Data {
        guard let url = URL(string: qrURL) else {
            throw CredentialError.invalidQRData
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
