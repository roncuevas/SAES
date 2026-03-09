struct DebugFetchResponse: Codable {
    let success: Bool
    let count: Int
    let urls: [DebugFetchURL]
}

struct DebugFetchURL: Codable {
    let hash: String
    let url: String
}
