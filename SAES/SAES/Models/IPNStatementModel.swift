import Foundation
import SwiftUI

struct IPNStatementModelElement: Codable, Identifiable, Hashable {
    var id = UUID()
    let title, imageURL, link, date: String
    
    enum CodingKeys: CodingKey {
        case title
        case imageURL
        case link
        case date
    }
}

typealias IPNStatementModel = [IPNStatementModelElement]
