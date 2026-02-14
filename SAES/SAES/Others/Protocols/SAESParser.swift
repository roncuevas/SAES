import Foundation
import SwiftSoup

protocol SAESParser: Sendable {
    func convert(_ data: Data) throws -> Document
}

extension SAESParser {
    func convert(_ data: Data) throws -> Document {
        guard let string = String(data: data, encoding: .utf8)
        else { throw SAESParserError.dataIsNotUTF8 }
        return try SwiftSoup.parse(string)
    }
}

extension Element {
    func select(_ selectors: [String]) throws -> Element {
        for selector in selectors {
            guard let element = try? self.select(selector).first() else { continue }
            return element
        }
        throw SAESParserError.nodeNotFound
    }
}
