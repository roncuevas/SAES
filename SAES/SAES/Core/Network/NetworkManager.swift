import Alamofire
import Foundation

class NetworkManager {
    static let shared: NetworkManager = NetworkManager()
    
    private init() {}
    
    func sendRequest<T: Codable>(url: String,
                                 method: HTTPMethod = .get,
                                 headers: HTTPHeaders? = nil,
                                 body: [String: Any]? = nil,
                                 type: T.Type) async throws -> T {
        let dataTask = AF.request(url,
                                  method: .post,
                                  parameters: body,
                                  encoding: JSONEncoding.default,
                                  headers: headers).serializingDecodable(type.self)
        return try await dataTask.value
    }
}
